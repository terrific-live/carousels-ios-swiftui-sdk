//
//  PlaybackStateTests.swift
//  MediaPlaybackTests
//

import XCTest
@testable import MediaPlayback

final class PlaybackStateTests: XCTestCase {

    // MARK: - PlaybackState Tests

    func testIdleState() {
        let state = PlaybackState.idle
        XCTAssertEqual(state, .idle)
    }

    func testLoadingState() {
        let state = PlaybackState.loading
        XCTAssertEqual(state, .loading)
    }

    func testReadyState() {
        let state = PlaybackState.ready
        XCTAssertEqual(state, .ready)
    }

    func testPlayingState() {
        let state = PlaybackState.playing
        XCTAssertEqual(state, .playing)
    }

    func testPausedState() {
        let state = PlaybackState.paused
        XCTAssertEqual(state, .paused)
    }

    func testFinishedState() {
        let state = PlaybackState.finished
        XCTAssertEqual(state, .finished)
    }

    func testErrorState() {
        let state = PlaybackState.error("Test error")
        if case .error(let message) = state {
            XCTAssertEqual(message, "Test error")
        } else {
            XCTFail("Expected error state")
        }
    }

    func testErrorStateEquality() {
        let state1 = PlaybackState.error("Error 1")
        let state2 = PlaybackState.error("Error 1")
        let state3 = PlaybackState.error("Error 2")

        XCTAssertEqual(state1, state2)
        XCTAssertNotEqual(state1, state3)
    }

    func testDifferentStatesAreNotEqual() {
        XCTAssertNotEqual(PlaybackState.idle, PlaybackState.loading)
        XCTAssertNotEqual(PlaybackState.ready, PlaybackState.playing)
        XCTAssertNotEqual(PlaybackState.paused, PlaybackState.finished)
    }

    // MARK: - PlaybackActionResult Tests

    func testSuccessResult() {
        let result = PlaybackActionResult.success
        XCTAssertEqual(result, .success)
    }

    func testInvalidStateResult() {
        let result = PlaybackActionResult.invalidState(
            current: .idle,
            allowed: [.ready, .paused]
        )
        if case .invalidState(let current, let allowed) = result {
            XCTAssertEqual(current, .idle)
            XCTAssertEqual(allowed, [.ready, .paused])
        } else {
            XCTFail("Expected invalidState result")
        }
    }

    func testNoPlayerResult() {
        let result = PlaybackActionResult.noPlayer
        XCTAssertEqual(result, .noPlayer)
    }

    func testSeekFailedResult() {
        let result = PlaybackActionResult.seekFailed
        XCTAssertEqual(result, .seekFailed)
    }

    // MARK: - PlaybackEngineConfiguration Tests

    func testDefaultConfiguration() {
        let config = PlaybackEngineConfiguration.default

        XCTAssertEqual(config.loadingTimeout, 30.0)
        XCTAssertEqual(config.maxRetryAttempts, 2)
        XCTAssertEqual(config.retryDelay, 1.0)
    }

    func testAggressiveConfiguration() {
        let config = PlaybackEngineConfiguration.aggressive

        XCTAssertEqual(config.loadingTimeout, 15.0)
        XCTAssertEqual(config.maxRetryAttempts, 3)
        XCTAssertEqual(config.retryDelay, 0.5)
    }

    func testCustomConfiguration() {
        let config = PlaybackEngineConfiguration(
            loadingTimeout: 60.0,
            maxRetryAttempts: 5,
            retryDelay: 2.0
        )

        XCTAssertEqual(config.loadingTimeout, 60.0)
        XCTAssertEqual(config.maxRetryAttempts, 5)
        XCTAssertEqual(config.retryDelay, 2.0)
    }
}
