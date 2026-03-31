//
//  PlaybackState.swift
//  MediaPlayback
//

import Foundation

// MARK: - PlaybackState
public enum PlaybackState: Equatable, Sendable {
    case idle
    case loading
    case ready // The playhead is at a valid position, buffered, and waiting for a play command
    case playing
    case paused
    case finished // The playhead is at the end
    case error(String)
}
