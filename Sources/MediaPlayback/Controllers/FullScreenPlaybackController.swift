//
//  FullScreenPlaybackController.swift
//  MediaPlayback
//

import Foundation

/// Controller for full-screen playback (immediate start, infinite loop via AVPlayerLooper)
@MainActor
public final class FullScreenPlaybackController: PlaybackControllerProtocol {

    // MARK: - State

    private var isActive = false

    // MARK: - Init

    public init() {}

    // MARK: - PlaybackControllerProtocol

    public func start(
        onShowVideo: @escaping () -> Void,
        onFinish: @escaping () -> Void
    ) {
        log("start - immediate playback, infinite loop")
        stop()

        isActive = true

        // Full-screen shows video immediately (no delay)
        log("calling onShowVideo immediately")
        onShowVideo()

        // Note: onFinish is never called for full-screen since it loops infinitely
        // The loop is handled by AVPlayerLooper in the engine
    }

    public func stop() {
        if isActive {
            log("stop")
        }
        isActive = false
    }

    // MARK: - Test Helpers

    /// Returns whether the controller is active (for testing)
    public var testIsActive: Bool {
        isActive
    }

    private func log(_ message: String) {
        logMediaPlayback("[FullScreenController] \(message)")
    }
}
