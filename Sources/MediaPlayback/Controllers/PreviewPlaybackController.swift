//
//  PreviewPlaybackController.swift
//  MediaPlayback
//

import Foundation

/// Controller for preview-style playback (delay, duration, optional loop)
@MainActor
public final class PreviewPlaybackController: PlaybackControllerProtocol {

    // MARK: - Configuration

    private let delay: TimeInterval
    private let duration: TimeInterval
    private let shouldLoop: Bool

    // MARK: - State

    private var task: Task<Void, Never>?
    private var onShowVideoCallback: (() -> Void)?
    private var onFinishCallback: (() -> Void)?

    // MARK: - Init

    public init(
        delay: TimeInterval,
        duration: TimeInterval,
        shouldLoop: Bool
    ) {
        self.delay = delay
        self.duration = duration
        self.shouldLoop = shouldLoop
    }

    // MARK: - PlaybackControllerProtocol

    public func start(
        onShowVideo: @escaping () -> Void,
        onFinish: @escaping () -> Void
    ) {
        log("start - delay=\(delay)s, duration=\(duration)s, loop=\(shouldLoop)")

        // Store callbacks
        self.onShowVideoCallback = onShowVideo
        self.onFinishCallback = onFinish

        // Stop any existing cycle
        stop()

        // Start new cycle
        startCycle()
    }

    // MARK: - Private

    private func startCycle() {
        task = Task { [weak self] in
            guard let self else { return }

            // Step 1: Wait for delay
            log("waiting \(self.delay)s before showing video")
            try? await Task.sleep(nanoseconds: UInt64(self.delay * 1_000_000_000))
            guard !Task.isCancelled else {
                log("❌ cancelled during delay")
                return
            }

            // Step 2: Show video
            log("delay complete, calling onShowVideo")
            self.onShowVideoCallback?()

            // Step 3: Wait for duration (if not infinite)
            guard self.duration != .infinity else {
                log("duration is infinity, not scheduling finish")
                return
            }

            log("waiting \(self.duration)s before finishing")
            try? await Task.sleep(nanoseconds: UInt64(self.duration * 1_000_000_000))
            guard !Task.isCancelled else {
                log("❌ cancelled during playback")
                return
            }

            // Step 4: Finish
            log("playback duration complete, calling onFinish")
            self.onFinishCallback?()

            // Step 5: Loop if needed
            if self.shouldLoop {
                log("shouldLoop=true, restarting cycle")
                self.startCycle()
            } else {
                log("preview cycle complete")
            }
        }
    }

    public func stop() {
        if task != nil {
            log("stop - cancelling existing task")
            task?.cancel()
            task = nil
        }
    }

    // MARK: - Test Helpers

    /// Returns whether a task is currently running (for testing)
    public var testHasActiveTask: Bool {
        task != nil
    }

    /// Returns the configured delay (for testing)
    public var testDelay: TimeInterval {
        delay
    }

    /// Returns the configured duration (for testing)
    public var testDuration: TimeInterval {
        duration
    }

    /// Returns whether looping is enabled (for testing)
    public var testShouldLoop: Bool {
        shouldLoop
    }

    private func log(_ message: String) {
        logMediaPlayback("[PreviewController] \(message)")
    }
}
