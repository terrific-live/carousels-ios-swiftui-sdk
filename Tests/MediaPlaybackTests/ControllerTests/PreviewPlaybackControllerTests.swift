//
//  PreviewPlaybackControllerTests.swift
//  MediaPlaybackTests
//

import XCTest
@testable import MediaPlayback

@MainActor
final class PreviewPlaybackControllerTests: XCTestCase {

    // MARK: - Initialization Tests

    func testInitializationWithParameters() {
        let controller = PreviewPlaybackController(
            delay: 1.5,
            duration: 5.0,
            shouldLoop: true
        )

        XCTAssertEqual(controller.testDelay, 1.5)
        XCTAssertEqual(controller.testDuration, 5.0)
        XCTAssertTrue(controller.testShouldLoop)
    }

    func testInitialStateHasNoActiveTask() {
        let controller = PreviewPlaybackController(
            delay: 0,
            duration: 1.0,
            shouldLoop: false
        )

        XCTAssertFalse(controller.testHasActiveTask)
    }

    // MARK: - Start Tests

    func testStartCreatesActiveTask() {
        let controller = PreviewPlaybackController(
            delay: 10.0, // Long delay so task stays active
            duration: 5.0,
            shouldLoop: false
        )

        controller.start(
            onShowVideo: { },
            onFinish: { }
        )

        XCTAssertTrue(controller.testHasActiveTask)

        controller.stop()
    }

    func testStartWithZeroDelayCallsOnShowVideoQuickly() async throws {
        let controller = PreviewPlaybackController(
            delay: 0,
            duration: .infinity,
            shouldLoop: false
        )

        var showVideoCalled = false

        controller.start(
            onShowVideo: { showVideoCalled = true },
            onFinish: { }
        )

        // Wait a bit for the task to execute
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertTrue(showVideoCalled)

        controller.stop()
    }

    func testStartWithDelayWaitsBeforeCallingOnShowVideo() async throws {
        let controller = PreviewPlaybackController(
            delay: 0.2,
            duration: .infinity,
            shouldLoop: false
        )

        var showVideoCalled = false

        controller.start(
            onShowVideo: { showVideoCalled = true },
            onFinish: { }
        )

        // Check immediately - should not be called yet
        XCTAssertFalse(showVideoCalled)

        // Wait for delay to pass
        try await Task.sleep(nanoseconds: 250_000_000)

        XCTAssertTrue(showVideoCalled)

        controller.stop()
    }

    // MARK: - Stop Tests

    func testStopCancelsActiveTask() {
        let controller = PreviewPlaybackController(
            delay: 10.0,
            duration: 5.0,
            shouldLoop: false
        )

        controller.start(
            onShowVideo: { },
            onFinish: { }
        )

        controller.stop()

        XCTAssertFalse(controller.testHasActiveTask)
    }

    func testStopWhenNoActiveTask() {
        let controller = PreviewPlaybackController(
            delay: 1.0,
            duration: 5.0,
            shouldLoop: false
        )

        // Should not crash
        controller.stop()

        XCTAssertFalse(controller.testHasActiveTask)
    }

    // MARK: - Duration Tests

    func testFiniteDurationCallsOnFinish() async throws {
        let controller = PreviewPlaybackController(
            delay: 0,
            duration: 0.1,
            shouldLoop: false
        )

        var finishCalled = false

        controller.start(
            onShowVideo: { },
            onFinish: { finishCalled = true }
        )

        // Wait for delay + duration + buffer
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertTrue(finishCalled)
    }

    func testInfiniteDurationDoesNotCallOnFinish() async throws {
        let controller = PreviewPlaybackController(
            delay: 0,
            duration: .infinity,
            shouldLoop: false
        )

        var finishCalled = false

        controller.start(
            onShowVideo: { },
            onFinish: { finishCalled = true }
        )

        // Wait a bit
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertFalse(finishCalled)

        controller.stop()
    }

    // MARK: - Cancel During Delay Tests

    func testStopDuringDelayPreventsOnShowVideo() async throws {
        let controller = PreviewPlaybackController(
            delay: 0.5,
            duration: 1.0,
            shouldLoop: false
        )

        var showVideoCalled = false

        controller.start(
            onShowVideo: { showVideoCalled = true },
            onFinish: { }
        )

        // Stop before delay completes
        try await Task.sleep(nanoseconds: 100_000_000)
        controller.stop()

        // Wait for original delay to pass
        try await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertFalse(showVideoCalled)
    }

    // MARK: - Restart Tests

    func testStartStopsPreviousCycleAndStartsNew() {
        let controller = PreviewPlaybackController(
            delay: 10.0,
            duration: 5.0,
            shouldLoop: false
        )

        controller.start(
            onShowVideo: { },
            onFinish: { }
        )

        let firstTaskActive = controller.testHasActiveTask

        controller.start(
            onShowVideo: { },
            onFinish: { }
        )

        XCTAssertTrue(firstTaskActive)
        XCTAssertTrue(controller.testHasActiveTask)

        controller.stop()
    }
}
