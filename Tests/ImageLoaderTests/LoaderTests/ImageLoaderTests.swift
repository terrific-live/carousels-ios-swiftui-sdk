//
//  ImageLoaderTests.swift
//  ImageLoaderTests
//

import XCTest
@testable import ImageLoader

final class ImageLoaderTests: XCTestCase {

    var loader: ImageLoader!
    var mockCache: MockImageCache!

    override func setUp() async throws {
        mockCache = MockImageCache()
        loader = ImageLoader(
            cache: mockCache,
            configuration: .testing
        )
    }

    override func tearDown() async throws {
        await loader.cancelAllLoads()
        mockCache.reset()
        loader = nil
        mockCache = nil
    }

    // MARK: - Load from Cache Tests

    func testLoadFromCacheReturnsCachedImage() async {
        let url = createTestURL("cached-image")
        let cachedImage = createTestImage()
        mockCache.storedImages[url] = cachedImage

        let loadedImage = await loader.loadImage(from: url)

        XCTAssertNotNil(loadedImage)
        XCTAssertTrue(loadedImage === cachedImage)
    }

    // MARK: - Load from URL String Tests

    func testLoadFromInvalidURLStringReturnsNil() async {
        // Empty string is definitively invalid
        let invalidURLString = ""

        let loadedImage = await loader.loadImage(from: invalidURLString)

        XCTAssertNil(loadedImage)
    }

    func testLoadFromMalformedURLStringReturnsNil() async {
        // String with spaces should be invalid
        let malformedURLString = ":::invalid:::"

        let loadedImage = await loader.loadImage(from: malformedURLString)

        XCTAssertNil(loadedImage)
    }

    func testLoadFromValidURLString() async {
        let url = createTestURL("valid-string")
        let cachedImage = createTestImage()
        mockCache.storedImages[url] = cachedImage

        let loadedImage = await loader.loadImage(from: url.absoluteString)

        XCTAssertNotNil(loadedImage)
    }

    // MARK: - Cancel Tests

    func testCancelLoad() async {
        let url = createTestURL("cancel-test")

        await loader.cancelLoad(for: url)

        // Should not crash and active task count should be 0
        let count = await loader.activeTaskCount
        XCTAssertEqual(count, 0)
    }

    func testCancelAllLoads() async {
        await loader.cancelAllLoads()

        let count = await loader.activeTaskCount
        XCTAssertEqual(count, 0)
    }

    // MARK: - Active Task Tests

    func testActiveTaskCount() async {
        let count = await loader.activeTaskCount
        XCTAssertEqual(count, 0)
    }

    func testHasActiveTask() async {
        let url = createTestURL("active-task")

        let hasTask = await loader.hasActiveTask(for: url)
        XCTAssertFalse(hasTask)
    }

    // MARK: - Shared Instance Tests

    func testSharedInstanceExists() {
        let shared = ImageLoader.shared
        XCTAssertNotNil(shared)
    }

    // MARK: - Configuration Tests

    func testDefaultConfiguration() async {
        let defaultLoader = ImageLoader()
        XCTAssertNotNil(defaultLoader)
    }

    func testAggressiveConfiguration() async {
        let aggressiveLoader = ImageLoader(configuration: .aggressive)
        XCTAssertNotNil(aggressiveLoader)
    }

    // MARK: - Image Caching Tests

    func testImageIsCachedAfterLoad() async {
        let url = createTestURL("cache-after-load")
        let image = createTestImage()
        mockCache.storedImages[url] = image

        _ = await loader.loadImage(from: url)

        // Image was already in cache, so insertedURLs should be empty
        // (we're testing the cache hit path)
        XCTAssertTrue(mockCache.insertedURLs.isEmpty)
    }
}
