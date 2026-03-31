//
//  VideoPlaybackEngine.swift
//  MediaPlayback
//

import AVKit
import Combine
import Foundation

@MainActor
public final class VideoPlaybackEngine: ObservableObject, VideoPlaybackEngineProtocol {

    // MARK: - Published State (Interface)
    @Published
    public private(set) var state: PlaybackState = .idle

    @Published
    public private(set) var player: AVQueuePlayer?

    // MARK: - Protocol Publishers
    public var statePublisher: AnyPublisher<PlaybackState, Never> {
        $state.eraseToAnyPublisher()
    }

    public var playerPublisher: AnyPublisher<AVQueuePlayer?, Never> {
        $player.eraseToAnyPublisher()
    }

    // MARK: - Configuration
    private let configuration: PlaybackEngineConfiguration

    // MARK: - Internal State
    /// Inserts copies of the template item into the queue when the item reaches end.
    /// You keep a strong reference to the looper so it continues looping.
    /// Marked nonisolated(unsafe) to allow cleanup in deinit.
    private nonisolated(unsafe) var looper: AVPlayerLooper?
    private var cancellables = Set<AnyCancellable>()
    private var currentItem: AVPlayerItem? // AVQueuePlayer drops items after finish playing, we keep it to start playback again

    // MARK: - Timeout & Retry State
    private var loadingTimeoutTask: Task<Void, Never>?
    private var currentRetryCount = 0
    private var lastLoadRequest: (url: URL, loop: Bool)?

    // MARK: - Init
    public init(configuration: PlaybackEngineConfiguration = .default) {
        self.configuration = configuration
    }

    /// Ensure AVPlayerLooper is released even if handleCleanup() wasn't called.
    /// Prevents memory leak from AVPlayerLooper holding strong reference to player.
    deinit {
        looper?.disableLooping()
    }

    // MARK: - Intents (Actions)
    public func handleLoad(url: URL, loop: Bool) {
        log("handleLoad url=\(url.absoluteString) loop=\(loop)")

        // Store for potential retry
        lastLoadRequest = (url: url, loop: loop)

        cleanupResourcesOnly()
        cancelLoadingTimeout()

        // Configure asset with timeout options for network resources
        let assetOptions: [String: Any] = [
            AVURLAssetPreferPreciseDurationAndTimingKey: false,
        ]
        let asset = AVURLAsset(url: url, options: assetOptions)

        let item = AVPlayerItem(asset: asset)
        self.currentItem = item

        // Configure forward buffer duration for smoother playback
        item.preferredForwardBufferDuration = 2.0

        let player = AVQueuePlayer(playerItem: item)
        player.automaticallyWaitsToMinimizeStalling = true
        player.isMuted = true

        self.player = player

        if loop {
            looper = AVPlayerLooper(player: player, templateItem: item)
        }

        setupObservers(for: item)
        startLoadingTimeout()

        log("handleLoad - state change = loading (timeout: \(configuration.loadingTimeout)s)")
        state = .loading
    }

    @discardableResult
    public func handlePlay() -> PlaybackActionResult {
        log("handlePlay")

        let allowedStates: [PlaybackState] = [.ready, .paused, .finished]
        guard allowedStates.contains(state) else {
            log("❌ play() blocked - state must be .ready/.paused/.finished, current=\(state)")
            return .invalidState(current: state, allowed: allowedStates)
        }

        guard player != nil else {
            log("❌ play() blocked - no player")
            return .noPlayer
        }

        player?.play()
        log("handlePlay - state change = playing")
        state = .playing
        return .success
    }

    public func handlePause() {
        player?.pause()
        log("handlePause - state change = paused")
        state = .paused
    }

    @discardableResult
    public func handleSeekToStart() async -> PlaybackActionResult {
        log("handleSeekToStart")
        guard let player = player else {
            log("❌ seekToStart() blocked - no player")
            return .noPlayer
        }

        // 1. Check if the player emptied the queue (currentItem is nil)
        if player.currentItem == nil, let item = self.currentItem {
            log("♻️ Queue empty. Re-inserting item to restart.")

            // Reset the item's time to zero before inserting
            await item.seek(to: .zero)

            player.insert(item, after: nil)
        }

        let completed = await player.seek(to: .zero)

        log("seek completed=\(completed)")

        if completed && state == .finished {
            state = .ready
        }

        return completed ? .success : .seekFailed
    }

    public func handleCleanup() {
        cleanup()
    }

    public func handleRetry() {
        retryLoad()
    }

    // MARK: - Test Helpers

    /// Returns the current retry count (for testing)
    public var testCurrentRetryCount: Int {
        currentRetryCount
    }

    /// Returns whether there's a pending load request (for testing)
    public var testHasLastLoadRequest: Bool {
        lastLoadRequest != nil
    }
}

// MARK: - Private Logic
private extension VideoPlaybackEngine {

    func cleanup() {
        log("cleanup - state change = idle")
        state = .idle
        currentRetryCount = 0
        lastLoadRequest = nil
        cancelLoadingTimeout()
        cleanupResourcesOnly()
    }

    func cleanupResourcesOnly() {
        log("cleanupResourcesOnly")
        player?.pause()

        // Reset Looper
        looper?.disableLooping()
        looper = nil

        // Reset Player
        player?.removeAllItems()
        player = nil

        // Reset Subscriptions (but NOT state)
        cancellables.removeAll()
    }

    // MARK: - Timeout Handling

    func startLoadingTimeout() {
        loadingTimeoutTask = Task { [weak self, configuration] in
            do {
                try await Task.sleep(nanoseconds: UInt64(configuration.loadingTimeout * 1_000_000_000))
                self?.handleLoadingTimeout()
            } catch {
                // Task was cancelled - expected when loading succeeds or is stopped
            }
        }
    }

    func cancelLoadingTimeout() {
        loadingTimeoutTask?.cancel()
        loadingTimeoutTask = nil
    }

    func handleLoadingTimeout() {
        guard state == .loading else {
            log("Timeout fired but state is \(state), ignoring")
            return
        }

        log("⏱️ Loading timeout after \(configuration.loadingTimeout)s")
        attemptRetryOrFail(errorMessage: "Loading timeout - video took too long to load")
    }

    // MARK: - Unified Retry Logic

    func attemptRetryOrFail(errorMessage: String) {
        guard let request = lastLoadRequest else {
            log("❌ Cannot retry - no previous load request stored")
            state = .error(errorMessage)
            return
        }

        if currentRetryCount < configuration.maxRetryAttempts {
            currentRetryCount += 1
            log("🔄 Retry attempt \(currentRetryCount)/\(configuration.maxRetryAttempts)")
            scheduleRetry(request: request)
        } else {
            log("❌ Retries exhausted (\(currentRetryCount)/\(configuration.maxRetryAttempts))")
            state = .error(errorMessage)
            currentRetryCount = 0
        }
    }

    func scheduleRetry(request: (url: URL, loop: Bool)) {
        Task { [weak self, configuration] in
            do {
                try await Task.sleep(nanoseconds: UInt64(configuration.retryDelay * 1_000_000_000))
                self?.handleLoad(url: request.url, loop: request.loop)
            } catch {
                self?.log("Retry cancelled")
            }
        }
    }

    func retryLoad() {
        guard let request = lastLoadRequest else {
            log("❌ Cannot retry - no previous load request")
            return
        }

        log("🔄 Manual retry requested")
        currentRetryCount = 0
        handleLoad(url: request.url, loop: request.loop)
    }

    func setupObservers(for item: AVPlayerItem) {
        log("setupObservers")
        // Observer: Status
        item.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                self.handleStatusChange(status, for: item)
            }
            .store(in: &cancellables)

        // Observer: Buffer status
        item.publisher(for: \.isPlaybackLikelyToKeepUp)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLikelyToKeepUp in
                guard let self else { return }
                self.log("buffer status: isPlaybackLikelyToKeepUp=\(isLikelyToKeepUp)")
            }
            .store(in: &cancellables)

        // Observer: DidPlayToEndTime
        NotificationCenter.default.publisher(
            for: .AVPlayerItemDidPlayToEndTime,
            object: item
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
            self?.handlePlaybackFinished()
        }
        .store(in: &cancellables)
    }

    func handleStatusChange(_ status: AVPlayerItem.Status, for item: AVPlayerItem) {
        log("handleStatusChange \(status.rawValue)")

        switch status {
        case .readyToPlay:
            cancelLoadingTimeout()
            currentRetryCount = 0
            log("handleStatusChange - state change = ready")
            state = .ready

        case .failed:
            cancelLoadingTimeout()
            let errorMessage = item.error?.localizedDescription ?? "Unknown error"
            logDetailedError(for: item)
            attemptRetryOrFail(errorMessage: errorMessage)

        default:
            log("handleStatusChange item.status=\(status.rawValue) (ignored)")
        }
    }

    func handlePlaybackFinished() {
        log("handlePlaybackFinished - state change = finished")
        state = .finished
    }

    // MARK: - Logging Helpers

    func log(_ message: String) {
        logMediaPlayback("[Engine] \(message)")
    }

    func logDetailedError(for item: AVPlayerItem) {
        let errorMessage = item.error?.localizedDescription ?? "Unknown error"
        log("❌ Playback failed: \(errorMessage)")

        if let error = item.error as NSError? {
            log("❌ Error domain: \(error.domain), code: \(error.code)")
            if let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NSError {
                log("❌ Underlying: \(underlyingError.localizedDescription)")
            }
        }

        if let errorLog = item.errorLog() {
            for event in errorLog.events {
                log("❌ Event: \(event.errorStatusCode) - \(event.errorComment ?? "no comment")")
            }
        }
    }
}
