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
        XCTAssertEqual(config.showDelay, 2.5)
        XCTAssertEqual(config.maxPlaybackDuration, 5.0)
        XCTAssertFalse(config.shouldLoopPreview)
        XCTAssertEqual(config.playback, .restartOnPreview)
    }

    func testFullScreenConfiguration() {
        let config = VideoPreviewConfiguration.fullScreen

        XCTAssertEqual(config.playbackMode, .fullScreen)
        XCTAssertEqual(config.showDelay, 0)
        XCTAssertEqual(config.maxPlaybackDuration, .infinity)
        XCTAssertFalse(config.shouldLoopPreview)
        XCTAssertEqual(config.playback, .loop)
    }

    // MARK: - Custom Configuration Tests

    func testCustomConfiguration() {
        let config = VideoPreviewConfiguration(
            playbackMode: .preview,
            showDelay: 1.5,
            maxPlaybackDuration: 10.0,
            shouldLoopPreview: true,
            playback: .playOnce
        )

        XCTAssertEqual(config.playbackMode, .preview)
        XCTAssertEqual(config.showDelay, 1.5)
        XCTAssertEqual(config.maxPlaybackDuration, 10.0)
        XCTAssertTrue(config.shouldLoopPreview)
        XCTAssertEqual(config.playback, .playOnce)
    }

    func testDefaultValues() {
        let config = VideoPreviewConfiguration()

        XCTAssertEqual(config.playbackMode, .preview)
        XCTAssertEqual(config.showDelay, 0)
        XCTAssertEqual(config.maxPlaybackDuration, .infinity)
        XCTAssertFalse(config.shouldLoopPreview)
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

    // MARK: - VisibilityBehavior Tests

    func testVisibilityBehaviorManual() {
        let behavior = VisibilityBehavior.manual
        XCTAssertEqual(behavior, .manual)
    }

    func testVisibilityBehaviorAutoPlay() {
        let behavior = VisibilityBehavior.autoPlay(threshold: 0.5)
        if case .autoPlay(let threshold) = behavior {
            XCTAssertEqual(threshold, 0.5)
        } else {
            XCTFail("Expected autoPlay behavior")
        }
    }

    func testVisibilityBehaviorEquality() {
        XCTAssertEqual(
            VisibilityBehavior.autoPlay(threshold: 0.5),
            VisibilityBehavior.autoPlay(threshold: 0.5)
        )
        XCTAssertNotEqual(
            VisibilityBehavior.autoPlay(threshold: 0.5),
            VisibilityBehavior.autoPlay(threshold: 0.7)
        )
    }

    // MARK: - AudioBehavior Tests

    func testAudioBehavior() {
        let muted = AudioBehavior(isMuted: true)
        let unmuted = AudioBehavior(isMuted: false)

        XCTAssertTrue(muted.isMuted)
        XCTAssertFalse(unmuted.isMuted)
    }

    // MARK: - AnalyticsBehavior Tests

    func testAnalyticsBehavior() {
        let tracking = AnalyticsBehavior(shouldTrack: true)
        let notTracking = AnalyticsBehavior(shouldTrack: false)

        XCTAssertTrue(tracking.shouldTrack)
        XCTAssertFalse(notTracking.shouldTrack)
    }
}
