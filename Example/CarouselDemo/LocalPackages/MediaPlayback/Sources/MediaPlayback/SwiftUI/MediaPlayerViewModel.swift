//
//  MediaPlayerViewModel.swift
//  MediaPlayback
//

import Combine
import AVKit
import Foundation

@MainActor
public final class MediaPlayerViewModel: ObservableObject {
    public let instanceId = UUID().uuidString.prefix(8)

    // MARK: - Published State (Interface)
    @Published
    public private(set) var player: AVPlayer?

    /// Controls whether the video layer should be shown in the view hierarchy
    @Published
    public private(set) var showVideo = true

    /// Controls the crossfade animation (image alpha vs video alpha)
    @Published
    public private(set) var isPlaying = false

    /// Indicates if video is currently loading
    @Published
    public private(set) var isLoading = false

    /// Video playback progress (0.0 to 1.0)
    @Published
    public private(set) var progress: Double = 0

    /// Indicates if video has valid duration (false means broken/invalid video)
    @Published
    public private(set) var hasValidPlayback: Bool = false

    /// Controls whether video is muted
    @Published
    public var isMuted: Bool = true {
        didSet {
            player?.isMuted = isMuted
        }
    }

    /// Publisher that emits when video finishes playing
    public var videoFinishedPublisher: AnyPublisher<Void, Never> {
        videoFinishedSubject.eraseToAnyPublisher()
    }
    private let videoFinishedSubject = PassthroughSubject<Void, Never>()

    /// Time observer token for progress tracking
    private var timeObserverToken: Any?

    // MARK: - Dependencies
    private let engine: VideoPlaybackEngineProtocol

    // MARK: - Inputs
    private var url: URL?
    private var configuration: VideoPreviewConfiguration = .fullScreen // default

    // MARK: - Init
    /// Initialize with default engine
    public init() {
        self.engine = VideoPlaybackEngine()
        self.bindEngine()
    }

    /// Initialize with a custom engine (for testing)
    /// - Parameter engine: The playback engine to use. Inject a mock for testing.
    public init(engine: VideoPlaybackEngineProtocol) {
        self.engine = engine
        self.bindEngine()
    }

    // MARK: - Internal State
    private var cancellables = Set<AnyCancellable>()
    private var pendingPlay = false
}

// MARK: - Intents (Actions)
public extension MediaPlayerViewModel {
    func handleLoad(url: URL?, configuration: VideoPreviewConfiguration) {
        // Prevent reloading if nothing changed
        guard self.url != url || self.configuration != configuration else {
            return
        }

        self.url = url
        self.configuration = configuration

        guard let url = url else {
            // Handle case where URL is nil (e.g. clear player)
            engine.handleCleanup()
            return
        }

        log("handleLoad called with url: \(url.lastPathComponent)")

        let shouldLoop = (configuration.playback == .loop)
        engine.handleLoad(url: url, loop: shouldLoop)
    }

    func handleStartPlayback() {
        log("handleStartPlayback, engine state=\(engine.state)")
        // 1. Mark intent to show video
        showVideo = true

        // 2. Set pending play flag (in case video still loading)
        pendingPlay = true

        // 3. Try to play immediately if ready
        Task {
            // 3. Prepare Engine - seek to start if needed
            // For .restartOnPreview and .playOnce, always restart from beginning
            let shouldSeekToStart = configuration.playback == .restartOnPreview ||
                configuration.playback == .playOnce

            if shouldSeekToStart {
                log("resetting player to start (playback=\(configuration.playback), state=\(engine.state))")
                let seekResult = await engine.handleSeekToStart()
                handleActionResult(seekResult, action: "seekToStart")
                await sleepWithLogging(seconds: 0.1, reason: "state settle delay")
            }

            attemptToPlay()
        }
    }

    func handleStopPlayback() {
        log("handleStopPlayback - state=\(engine.state)")

        // Reset ViewModel-owned state (not derived from engine)
        showVideo = false
        pendingPlay = false
        hasValidPlayback = false

        // Stop engine - this triggers state change to .paused
        engine.handlePause()
    }

    func handleCleanup() {
        // Reset ViewModel-owned state (not derived from engine)
        showVideo = false
        pendingPlay = false
        progress = 0
        hasValidPlayback = false

        // Remove time observer
        if let token = timeObserverToken, let player = player {
            player.removeTimeObserver(token)
            timeObserverToken = nil
        }

        // Cleanup engine
        engine.handleCleanup()
    }

    /// Retry loading after an error
    func handleRetry() {
        log("handleRetry requested")
        engine.handleRetry()
    }
}

// MARK: - Private Logic
private extension MediaPlayerViewModel {
    func bindEngine() {
        // Observe State via protocol publisher
        engine.statePublisher
            .removeDuplicates()
            .sink { [weak self] state in
                self?.handleEngineStateChange(state)

                // Defer to next run loop to ensure state is fully settled
                Task { @MainActor [weak self] in
                    self?.attemptToPlay()
                }
            }
            .store(in: &cancellables)

        // Observe Player via protocol publisher
        engine.playerPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] player in
                self?.handleEnginePlayerChange(player)
            }
            .store(in: &cancellables)
    }

    func attemptToPlay() {
        guard pendingPlay else {
            return
        }
        let currentState = engine.state
        // Engine allows playing from .ready, .paused, or .finished states
        if currentState == .ready || currentState == .paused || currentState == .finished {
            log("attemptToPlay, engine state=\(currentState), pendingPlay=\(pendingPlay), calling engine.handlePlay")
            pendingPlay = false

            let result = engine.handlePlay()
            handleActionResult(result, action: "play")
        }
    }

    func handleActionResult(_ result: PlaybackActionResult, action: String) {
        switch result {
        case .success:
            break // Already logged in engine
        case .invalidState(let current, let allowed):
            log("⚠️ \(action) failed: invalid state \(current), allowed: \(allowed)")
        case .noPlayer:
            log("⚠️ \(action) failed: no player available")
        case .seekFailed:
            log("⚠️ \(action) failed: seek operation did not complete")
        }
    }

    func handleEngineStateChange(_ engineState: PlaybackState) {
        log("handleEngineStateChange: \(engineState)")

        // Derive UI state directly from engine state
        isPlaying = (engineState == .playing)
        isLoading = (engineState == .loading)

        // Notify when video finishes
        if engineState == .finished {
            videoFinishedSubject.send()
        }
    }

    func handleEnginePlayerChange(_ newPlayer: AVPlayer?) {
        log("player updated")

        // Remove old time observer
        if let token = timeObserverToken, let oldPlayer = self.player {
            oldPlayer.removeTimeObserver(token)
            timeObserverToken = nil
        }

        self.player = newPlayer
        progress = 0
        hasValidPlayback = false

        // Apply mute state and add time observer
        if let player = newPlayer {
            player.isMuted = isMuted
            setupProgressObserver(for: player)
        }
    }

    func setupProgressObserver(for player: AVPlayer) {
        // Update progress every 0.1 seconds
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }

            guard let duration = player.currentItem?.duration,
                  duration.isNumeric,
                  !duration.seconds.isNaN,
                  duration.seconds > 0 else {
                return
            }

            let currentTime = time.seconds
            let totalDuration = duration.seconds
            let newProgress = min(max(currentTime / totalDuration, 0), 1)

            // Mark as valid playback only when video actually makes progress (> 0)
            // This ensures broken videos that have valid duration but can't decode are detected
            if !self.hasValidPlayback && newProgress > 0.01 {
                self.hasValidPlayback = true
                self.log("✅ Video has valid playback: progress=\(newProgress), duration=\(totalDuration)s")
            }

            if abs(self.progress - newProgress) > 0.001 {
                self.progress = newProgress
            }
        }
    }
}

// MARK: - Helpers
private extension MediaPlayerViewModel {
    func log(_ message: String) {
        logMediaPlayback("[ViewModel-\(instanceId)] \(message)")
    }

    func sleepWithLogging(seconds: Double, reason: String) async {
        do {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
        } catch {
            log("Sleep interrupted (\(reason)): \(error.localizedDescription)")
        }
    }
}
