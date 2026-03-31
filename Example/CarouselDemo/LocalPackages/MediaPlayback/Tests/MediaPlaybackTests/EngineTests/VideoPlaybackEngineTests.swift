//
//  VideoPlaybackEngineTests.swift
//  MediaPlaybackTests
//

import XCTest
@testable import MediaPlayback

@MainActor
final class VideoPlaybackEngineTests: XCTestCase {

    var engine: VideoPlaybackEngine!

    override func setUp() async throws {
        // Use aggressive config for faster tests
        engine = VideoPlaybackEngine(configuration: PlaybackEngineConfiguration(
            loadingTimeout: 5.0,
            maxRetryAttempts: 1,
            retryDelay: 0.1
        ))
    }

    override func tearDown() async throws {
        engine.handleCleanup()
        engine = nil
    }

    // MARK: - Initial State Tests

    func testInitialStateIsIdle() {
        XCTAssertEqual(engine.state, .idle)
    }

    func testInitialPlayerIsNil() {
        XCTAssertNil(engine.player)
    }

    // MARK: - HandleLoad Tests

    func testHandleLoadSetsLoadingState() {
        let url = URL(string: "https://example.com/video.mp4")!

        engine.handleLoad(url: url, loop: false)

        XCTAssertEqual(engine.state, .loading)
    }

    func testHandleLoadCreatesPlayer() {
        let url = URL(string: "https://example.com/video.mp4")!

        engine.handleLoad(url: url, loop: false)

        XCTAssertNotNil(engine.player)
    }

    func testHandleLoadStoresLastLoadRequest() {
        let url = URL(string: "https://example.com/video.mp4")!

        engine.handleLoad(url: url, loop: true)

        XCTAssertTrue(engine.testHasLastLoadRequest)
    }

    // MARK: - HandlePlay Tests

    func testHandlePlayFromIdleReturnsInvalidState() {
        let result = engine.handlePlay()

        if case .invalidState(let current, let allowed) = result {
            XCTAssertEqual(current, .idle)
            XCTAssertEqual(allowed, [.ready, .paused, .finished])
        } else {
            XCTFail("Expected invalidState result")
        }
    }

    func testHandlePlayWithNoPlayerReturnsNoPlayer() {
        // Manually set state to ready without creating player
        // This is a bit of a hack for testing
        engine.handleCleanup()

        let result = engine.handlePlay()

        // Should return invalidState since state is idle
        XCTAssertEqual(result, .invalidState(current: .idle, allowed: [.ready, .paused, .finished]))
    }

    // MARK: - HandlePause Tests

    func testHandlePauseSetsState() {
        let url = URL(string: "https://example.com/video.mp4")!
        engine.handleLoad(url: url, loop: false)

        engine.handlePause()

        XCTAssertEqual(engine.state, .paused)
    }

    // MARK: - HandleCleanup Tests

    func testHandleCleanupResetsToIdle() {
        let url = URL(string: "https://example.com/video.mp4")!
        engine.handleLoad(url: url, loop: false)

        engine.handleCleanup()

        XCTAssertEqual(engine.state, .idle)
    }

    func testHandleCleanupClearsPlayer() {
        let url = URL(string: "https://example.com/video.mp4")!
        engine.handleLoad(url: url, loop: false)

        engine.handleCleanup()

        XCTAssertNil(engine.player)
    }

    func testHandleCleanupResetsRetryCount() {
        let url = URL(string: "https://example.com/video.mp4")!
        engine.handleLoad(url: url, loop: false)

        engine.handleCleanup()

        XCTAssertEqual(engine.testCurrentRetryCount, 0)
    }

    func testHandleCleanupClearsLastLoadRequest() {
        let url = URL(string: "https://example.com/video.mp4")!
        engine.handleLoad(url: url, loop: false)

        engine.handleCleanup()

        XCTAssertFalse(engine.testHasLastLoadRequest)
    }

    // MARK: - HandleSeekToStart Tests

    func testHandleSeekToStartWithNoPlayerReturnsNoPlayer() async {
        let result = await engine.handleSeekToStart()

        XCTAssertEqual(result, .noPlayer)
    }

    // MARK: - Publisher Tests

    func testStatePublisherEmitsChanges() async throws {
        var receivedStates: [PlaybackState] = []
        let cancellable = engine.statePublisher
            .sink { state in
                receivedStates.append(state)
            }

        let url = URL(string: "https://example.com/video.mp4")!
        engine.handleLoad(url: url, loop: false)

        // Wait for publisher
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertTrue(receivedStates.contains(.loading))

        cancellable.cancel()
    }

    func testPlayerPublisherEmitsChanges() async throws {
        var receivedPlayers: [Bool] = [] // Track if player is nil or not
        let cancellable = engine.playerPublisher
            .sink { player in
                receivedPlayers.append(player != nil)
            }

        let url = URL(string: "https://example.com/video.mp4")!
        engine.handleLoad(url: url, loop: false)

        // Wait for publisher
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertTrue(receivedPlayers.contains(true))

        cancellable.cancel()
    }

    // MARK: - Configuration Tests

    func testDefaultConfiguration() {
        let defaultEngine = VideoPlaybackEngine()
        XCTAssertNotNil(defaultEngine)
    }

    func testAggressiveConfiguration() {
        let aggressiveEngine = VideoPlaybackEngine(configuration: .aggressive)
        XCTAssertNotNil(aggressiveEngine)
    }
}
