//
//  MediaPlayerViewModelTests.swift
//  MediaPlaybackTests
//

import XCTest
@testable import MediaPlayback

@MainActor
final class MediaPlayerViewModelTests: XCTestCase {

    var viewModel: MediaPlayerViewModel!
    var mockEngine: MockVideoPlaybackEngine!

    override func setUp() async throws {
        mockEngine = MockVideoPlaybackEngine()
        viewModel = MediaPlayerViewModel(engine: mockEngine)
    }

    override func tearDown() async throws {
        viewModel.handleCleanup()
        mockEngine.reset()
        viewModel = nil
        mockEngine = nil
    }

    // MARK: - Initial State Tests

    func testInitialState() {
        XCTAssertNil(viewModel.player)
        XCTAssertTrue(viewModel.showVideo)
        XCTAssertFalse(viewModel.isPlaying)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testInstanceIdIsGenerated() {
        XCTAssertEqual(viewModel.instanceId.count, 8)
    }

    // MARK: - HandleLoad Tests

    func testHandleLoadWithValidURL() {
        let url = URL(string: "https://example.com/video.mp4")!
        let config = VideoPreviewConfiguration.fullScreen

        viewModel.handleLoad(url: url, configuration: config)

        XCTAssertEqual(mockEngine.loadedURLs.count, 1)
        XCTAssertEqual(mockEngine.loadedURLs.first, url)
    }

    func testHandleLoadWithLoopConfiguration() {
        let url = URL(string: "https://example.com/video.mp4")!
        let config = VideoPreviewConfiguration(playback: .loop)

        viewModel.handleLoad(url: url, configuration: config)

        XCTAssertEqual(mockEngine.loadedWithLoop.first, true)
    }

    func testHandleLoadWithPlayOnceConfiguration() {
        let url = URL(string: "https://example.com/video.mp4")!
        let config = VideoPreviewConfiguration(playback: .playOnce)

        viewModel.handleLoad(url: url, configuration: config)

        XCTAssertEqual(mockEngine.loadedWithLoop.first, false)
    }

    func testHandleLoadWithNilURLCallsCleanup() {
        // First load a valid URL so state changes
        let url = URL(string: "https://example.com/video.mp4")!
        viewModel.handleLoad(url: url, configuration: .fullScreen)

        // Now load with nil URL - should call cleanup
        viewModel.handleLoad(url: nil, configuration: .fullScreen)

        XCTAssertEqual(mockEngine.cleanupCallCount, 1)
    }

    func testHandleLoadDoesNotReloadSameURLAndConfig() {
        let url = URL(string: "https://example.com/video.mp4")!
        let config = VideoPreviewConfiguration.fullScreen

        viewModel.handleLoad(url: url, configuration: config)
        viewModel.handleLoad(url: url, configuration: config) // Same

        XCTAssertEqual(mockEngine.loadedURLs.count, 1)
    }

    // MARK: - HandleStartPlayback Tests

    func testHandleStartPlaybackSetsShowVideo() {
        viewModel.handleStartPlayback()

        XCTAssertTrue(viewModel.showVideo)
    }

    func testHandleStartPlaybackPlaysWhenReady() async throws {
        mockEngine.simulateReady()

        viewModel.handleStartPlayback()

        // Wait for async task
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(mockEngine.playCallCount, 1)
    }

    // MARK: - HandleStopPlayback Tests

    func testHandleStopPlaybackSetsShowVideoFalse() {
        viewModel.handleStartPlayback()
        viewModel.handleStopPlayback()

        XCTAssertFalse(viewModel.showVideo)
    }

    func testHandleStopPlaybackCallsPause() {
        viewModel.handleStopPlayback()

        XCTAssertEqual(mockEngine.pauseCallCount, 1)
    }

    // MARK: - HandleCleanup Tests

    func testHandleCleanupResetsState() {
        viewModel.handleStartPlayback()
        viewModel.handleCleanup()

        XCTAssertFalse(viewModel.showVideo)
        XCTAssertEqual(mockEngine.cleanupCallCount, 1)
    }

    // MARK: - HandleRetry Tests

    func testHandleRetryCallsEngineRetry() {
        viewModel.handleRetry()

        XCTAssertEqual(mockEngine.retryCallCount, 1)
    }

    // MARK: - Engine State Binding Tests

    func testIsPlayingUpdatesFromEngineState() async throws {
        mockEngine.simulatePlaying()

        // Wait for publisher to propagate
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertTrue(viewModel.isPlaying)
    }

    func testIsLoadingUpdatesFromEngineState() async throws {
        let url = URL(string: "https://example.com/video.mp4")!
        viewModel.handleLoad(url: url, configuration: .fullScreen)

        // Wait for publisher to propagate
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertTrue(viewModel.isLoading)
    }

    func testIsPlayingFalseWhenNotPlaying() async throws {
        mockEngine.simulatePaused()

        // Wait for publisher to propagate
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertFalse(viewModel.isPlaying)
    }

    // MARK: - RestartOnPreview Tests

    func testRestartOnPreviewSeeksToStart() async throws {
        let url = URL(string: "https://example.com/video.mp4")!
        let config = VideoPreviewConfiguration(playback: .restartOnPreview)

        viewModel.handleLoad(url: url, configuration: config)
        mockEngine.simulateReady()

        viewModel.handleStartPlayback()

        // Wait for async operations
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(mockEngine.seekToStartCallCount, 1)
    }
}

// MARK: - MockVideoPlaybackEngine Extension

private extension MockVideoPlaybackEngine {
    func simulatePaused() {
        state = .paused
    }
}
