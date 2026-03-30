//
//  MockVideoPlaybackEngine.swift
//  MediaPlaybackTests
//

import Foundation
import Combine
import AVKit
@testable import MediaPlayback

/// Mock video playback engine for testing
@MainActor
public final class MockVideoPlaybackEngine: VideoPlaybackEngineProtocol {

    // MARK: - Published State
    @Published
    public var state: PlaybackState = .idle

    @Published
    public var player: AVQueuePlayer?

    // MARK: - Protocol Publishers
    public var statePublisher: AnyPublisher<PlaybackState, Never> {
        $state.eraseToAnyPublisher()
    }

    public var playerPublisher: AnyPublisher<AVQueuePlayer?, Never> {
        $player.eraseToAnyPublisher()
    }

    // MARK: - Tracking
    public var loadedURLs: [URL] = []
    public var loadedWithLoop: [Bool] = []
    public var playCallCount = 0
    public var pauseCallCount = 0
    public var seekToStartCallCount = 0
    public var cleanupCallCount = 0
    public var retryCallCount = 0

    // MARK: - Configuration
    public var playResultToReturn: PlaybackActionResult = .success
    public var seekResultToReturn: PlaybackActionResult = .success

    public init() {}

    // MARK: - Protocol Methods

    public func handleLoad(url: URL, loop: Bool) {
        loadedURLs.append(url)
        loadedWithLoop.append(loop)
        state = .loading
    }

    @discardableResult
    public func handlePlay() -> PlaybackActionResult {
        playCallCount += 1
        if playResultToReturn == .success {
            state = .playing
        }
        return playResultToReturn
    }

    public func handlePause() {
        pauseCallCount += 1
        state = .paused
    }

    @discardableResult
    public func handleSeekToStart() async -> PlaybackActionResult {
        seekToStartCallCount += 1
        return seekResultToReturn
    }

    public func handleCleanup() {
        cleanupCallCount += 1
        state = .idle
        player = nil
    }

    public func handleRetry() {
        retryCallCount += 1
    }

    // MARK: - Test Helpers

    public func simulateReady() {
        state = .ready
    }

    public func simulatePlaying() {
        state = .playing
    }

    public func simulateFinished() {
        state = .finished
    }

    public func simulateError(_ message: String) {
        state = .error(message)
    }

    public func reset() {
        state = .idle
        player = nil
        loadedURLs = []
        loadedWithLoop = []
        playCallCount = 0
        pauseCallCount = 0
        seekToStartCallCount = 0
        cleanupCallCount = 0
        retryCallCount = 0
        playResultToReturn = .success
        seekResultToReturn = .success
    }
}
