//
//  VideoPreviewConfigurationTests.swift
//  MediaPlaybackTests
//

import XCTest
@testable import MediaPlayback

final class VideoPreviewConfigurationTests: XCTestCase {

    // MARK: - Preset Configuration Tests

    func testTimelineCardConfiguration() {
        let config = VideoPreviewConfiguration.timelineCard

        XCTAssertEqual(config.playbackMode, .preview)
        XCTAssertEqual(config.playback, .restartOnPreview)
    }

    func testFullScreenConfiguration() {
        let config = VideoPreviewConfiguration.fullScreen

        XCTAssertEqual(config.playbackMode, .fullScreen)
        XCTAssertEqual(config.playback, .loop)
    }

    func testFullScreenPlayOnceConfiguration() {
        let config = VideoPreviewConfiguration.fullScreenPlayOnce

        XCTAssertEqual(config.playbackMode, .fullScreen)
        XCTAssertEqual(config.playback, .playOnce)
    }

    // MARK: - Custom Configuration Tests

    func testCustomConfiguration() {
        let config = VideoPreviewConfiguration(
            playbackMode: .preview,
            playback: .playOnce
        )

        XCTAssertEqual(config.playbackMode, .preview)
        XCTAssertEqual(config.playback, .playOnce)
    }

    func testDefaultValues() {
        let config = VideoPreviewConfiguration()

        XCTAssertEqual(config.playbackMode, .preview)
        XCTAssertEqual(config.playback, .loop)
    }

    // MARK: - Equatable Tests

    func testConfigurationEquality() {
        let config1 = VideoPreviewConfiguration.timelineCard
        let config2 = VideoPreviewConfiguration.timelineCard
        let config3 = VideoPreviewConfiguration.fullScreen

        XCTAssertEqual(config1, config2)
        XCTAssertNotEqual(config1, config3)
    }

    // MARK: - PlaybackBehavior Tests

    func testPlaybackBehaviorEquality() {
        XCTAssertEqual(PlaybackBehavior.playOnce, PlaybackBehavior.playOnce)
        XCTAssertEqual(PlaybackBehavior.loop, PlaybackBehavior.loop)
        XCTAssertEqual(PlaybackBehavior.restartOnPreview, PlaybackBehavior.restartOnPreview)

        XCTAssertNotEqual(PlaybackBehavior.playOnce, PlaybackBehavior.loop)
        XCTAssertNotEqual(PlaybackBehavior.loop, PlaybackBehavior.restartOnPreview)
    }

    // MARK: - PlaybackMode Tests

    func testPlaybackModeEquality() {
        XCTAssertEqual(PlaybackMode.preview, PlaybackMode.preview)
        XCTAssertEqual(PlaybackMode.fullScreen, PlaybackMode.fullScreen)
        XCTAssertNotEqual(PlaybackMode.preview, PlaybackMode.fullScreen)
    }
}
