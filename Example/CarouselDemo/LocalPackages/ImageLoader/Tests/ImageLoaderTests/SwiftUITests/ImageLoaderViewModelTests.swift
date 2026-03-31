//
//  ImageLoaderViewModelTests.swift
//  ImageLoaderTests
//

import XCTest
@testable import ImageLoader

@MainActor
final class ImageLoaderViewModelTests: XCTestCase {

    var viewModel: ImageLoaderViewModel!
    var mockLoader: MockImageLoader!

    override func setUp() async throws {
        mockLoader = MockImageLoader()
        viewModel = ImageLoaderViewModel(imageLoader: mockLoader)
    }

    override func tearDown() async throws {
        viewModel.cancel()
        await mockLoader.reset()
        viewModel = nil
        mockLoader = nil
    }

    // MARK: - Initial State Tests

    func testInitialStateIsIdle() {
        XCTAssertEqual(viewModel.state, .idle)
    }

    func testIsLoadingInitiallyFalse() {
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLoadedImageInitiallyNil() {
        XCTAssertNil(viewModel.loadedImage)
    }

    func testErrorInitiallyNil() {
        XCTAssertNil(viewModel.error)
    }

    // MARK: - Load Tests

    func testLoadSetsLoadingStateImmediately() {
        let url = createTestURL("loading-state")

        // The state should be set to loading synchronously
        viewModel.load(from: url)

        // Check immediately - state should be loading
        XCTAssertEqual(viewModel.state, .loading)
    }

    func testLoadFromURLSuccess() async throws {
        let url = createTestURL("success")
        let image = createTestImage()
        await mockLoader.setImageToReturn(image)

        viewModel.load(from: url)

        // Poll for completion with timeout
        for _ in 0..<50 {
            if case .loaded = viewModel.state {
                break
            }
            try await Task.sleep(nanoseconds: 10_000_000) // 10ms
        }

        if case .loaded(let loadedImage) = viewModel.state {
            XCTAssertNotNil(loadedImage)
        } else {
            XCTFail("Expected loaded state, got \(viewModel.state)")
        }
    }

    func testLoadFromURLFailure() async throws {
        let url = createTestURL("failure")
        await mockLoader.setShouldFail(true)

        viewModel.load(from: url)

        // Poll for completion with timeout
        for _ in 0..<50 {
            if case .failed = viewModel.state {
                break
            }
            try await Task.sleep(nanoseconds: 10_000_000) // 10ms
        }

        if case .failed = viewModel.state {
            XCTAssertNotNil(viewModel.error)
        } else {
            XCTFail("Expected failed state, got \(viewModel.state)")
        }
    }

    // MARK: - Load from URL String Tests

    func testLoadFromInvalidURLStringSetsFailedState() {
        let invalidURLString = ""  // Empty string is definitively invalid

        viewModel.load(from: invalidURLString)

        if case .failed(let error) = viewModel.state {
            XCTAssertEqual(error as? ImageLoaderError, .invalidURL)
        } else {
            XCTFail("Expected failed state with invalidURL error")
        }
    }

    func testLoadFromValidURLString() async throws {
        let url = createTestURL("valid-string")
        let image = createTestImage()
        await mockLoader.setImageToReturn(image)

        viewModel.load(from: url.absoluteString)

        // Poll for completion with timeout
        for _ in 0..<50 {
            if viewModel.loadedImage != nil {
                break
            }
            try await Task.sleep(nanoseconds: 10_000_000) // 10ms
        }

        XCTAssertNotNil(viewModel.loadedImage)
    }

    // MARK: - Cancel Tests

    func testCancelResetsToIdleState() async throws {
        let url = createTestURL("cancel-test")
        viewModel.load(from: url)

        // Small delay to ensure load started
        try await Task.sleep(nanoseconds: 10_000_000)

        viewModel.cancel()

        XCTAssertEqual(viewModel.state, .idle)
    }

    func testCancelWhenIdle() {
        viewModel.cancel()
        XCTAssertEqual(viewModel.state, .idle)
    }

    // MARK: - Multiple Loads Tests

    func testMultipleLoadsCancelsPreviousLoad() async throws {
        let url1 = createTestURL("first")
        let url2 = createTestURL("second")
        let image = createTestImage()

        await mockLoader.setLoadDelay(100_000_000) // 0.1 seconds
        await mockLoader.setImageToReturn(image)

        viewModel.load(from: url1)
        viewModel.load(from: url2) // Should cancel the first load

        // Poll for completion with timeout
        for _ in 0..<100 {
            if case .loaded = viewModel.state {
                break
            }
            try await Task.sleep(nanoseconds: 10_000_000) // 10ms
        }

        let loadedURLs = await mockLoader.loadedURLs
        XCTAssertTrue(loadedURLs.contains(url2))
    }
}

// MARK: - MockImageLoader Helpers

private extension MockImageLoader {
    func setImageToReturn(_ image: PlatformImage?) async {
        imageToReturn = image
    }

    func setShouldFail(_ shouldFail: Bool) async {
        self.shouldFail = shouldFail
    }

    func setLoadDelay(_ delay: UInt64) async {
        loadDelay = delay
    }
}
