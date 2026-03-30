//
//  FullScreenPlaybackControllerTests.swift
//  MediaPlaybackTests
//

import XCTest
@testable import MediaPlayback

@MainActor
final class FullScreenPlaybackControllerTests: XCTestCase {

    var controller: FullScreenPlaybackController!

    override func setUp() async throws {
        controller = FullScreenPlaybackController()
    }

    override func tearDown() async throws {
        controller.stop()
        controller = nil
    }

    // MARK: - Initial State Tests

    func testInitialStateIsInactive() {
        XCTAssertFalse(controller.testIsActive)
    }

    // MARK: - Start Tests

    func testStartCallsOnShowVideoImmediately() {
        var showVideoCalled = false

        controller.start(
            onShowVideo: { showVideoCalled = true },
            onFinish: { }
        )

        XCTAssertTrue(showVideoCalled)
    }

    func testStartSetsActiveState() {
        controller.start(
            onShowVideo: { },
            onFinish: { }
        )

        XCTAssertTrue(controller.testIsActive)
    }

    func testOnFinishIsNeverCalledForFullScreen() async throws {
        var finishCalled = false

        controller.start(
            onShowVideo: { },
            onFinish: { finishCalled = true }
        )

        // Wait a bit to ensure onFinish is not called
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertFalse(finishCalled)
    }

    // MARK: - Stop Tests

    func testStopSetsInactiveState() {
        controller.start(
            onShowVideo: { },
            onFinish: { }
        )

        controller.stop()

        XCTAssertFalse(controller.testIsActive)
    }

    func testStopWhenAlreadyInactive() {
        // Should not crash
        controller.stop()
        XCTAssertFalse(controller.testIsActive)
    }

    // MARK: - Restart Tests

    func testStartStopsPreviousCycleAndStartsNew() {
        var showVideoCallCount = 0

        controller.start(
            onShowVideo: { showVideoCallCount += 1 },
            onFinish: { }
        )

        controller.start(
            onShowVideo: { showVideoCallCount += 1 },
            onFinish: { }
        )

        XCTAssertEqual(showVideoCallCount, 2)
        XCTAssertTrue(controller.testIsActive)
    }
}
