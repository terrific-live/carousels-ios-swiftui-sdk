//
//  PlaybackControllerProtocol.swift
//  MediaPlayback
//

import Foundation

/// Protocol for playback controllers that manage video playback timing and lifecycle
@MainActor
public protocol PlaybackControllerProtocol {

    /// Start the playback cycle
    /// - Parameters:
    ///   - onShowVideo: Called when video should be shown and playback should begin
    ///   - onFinish: Called when playback cycle completes (may not be called for infinite loops)
    func start(
        onShowVideo: @escaping () -> Void,
        onFinish: @escaping () -> Void
    )

    /// Stop the current playback cycle
    func stop()
}
