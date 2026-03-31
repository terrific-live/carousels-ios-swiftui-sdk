//
//  VideoPlaybackEngineProtocol.swift
//  MediaPlayback
//

import Foundation
import Combine
import AVKit

/// Protocol for video playback engine - enables dependency injection and testing
@MainActor
public protocol VideoPlaybackEngineProtocol: AnyObject {
    var state: PlaybackState { get }
    var statePublisher: AnyPublisher<PlaybackState, Never> { get }

    var player: AVQueuePlayer? { get }
    var playerPublisher: AnyPublisher<AVQueuePlayer?, Never> { get }

    func handleLoad(url: URL, loop: Bool)
    @discardableResult func handlePlay() -> PlaybackActionResult
    func handlePause()
    @discardableResult func handleSeekToStart() async -> PlaybackActionResult
    func handleCleanup()

    /// Retry loading the last requested video (useful after error state)
    func handleRetry()
}
