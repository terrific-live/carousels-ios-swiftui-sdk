//
//  PlaybackActionResult.swift
//  MediaPlayback
//

import Foundation

// MARK: - PlaybackActionResult
/// Result of an action attempt - enables callers to handle failures
public enum PlaybackActionResult: Equatable, Sendable {
    case success
    case invalidState(current: PlaybackState, allowed: [PlaybackState])
    case noPlayer
    case seekFailed
}
