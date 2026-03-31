//
//  ImageDiskCacheTests.swift
//  ImageLoaderTests
//

import XCTest
@testable import ImageLoader

final class ImageDiskCacheTests: XCTestCase {

    var diskCache: ImageDiskCache!

    override func setUp() async throws {
        diskCache = ImageDiskCache(configuration: .testing)
        await diskCache.clearCache()
    }

    override func tearDown() async throws {
        await diskCache.clearCache()
        diskCache = nil
    }

    // MARK: - Save and Load Tests

    func testSaveAndLoadImage() async {
        let url = createTestURL("save-load-test")
        let image = createTestImage()

        await diskCache.saveImage(image, for: url)
        let loadedImage = await diskCache.loadImage(for: url)

        XCTAssertNotNil(loadedImage)
    }

    func testLoadNonExistentImage() async {
        let url = createTestURL("non-existent")
        let loadedImage = await diskCache.loadImage(for: url)

        XCTAssertNil(loadedImage)
    }

    // MARK: - Remove Tests

    func testRemoveImage() async {
        let url = createTestURL("remove-test")
        let image = createTestImage()

        await diskCache.saveImage(image, for: url)
        await diskCache.removeImage(for: url)
        let loadedImage = await diskCache.loadImage(for: url)

        XCTAssertNil(loadedImage)
    }

    // MARK: - Clear Cache Tests

    func testClearCache() async {
        let url1 = createTestURL("clear-test-1")
        let url2 = createTestURL("clear-test-2")
        let image = createTestImage()

        await diskCache.saveImage(image, for: url1)
        await diskCache.saveImage(image, for: url2)
        await diskCache.clearCache()

        let loadedImage1 = await diskCache.loadImage(for: url1)
        let loadedImage2 = await diskCache.loadImage(for: url2)

        XCTAssertNil(loadedImage1)
        XCTAssertNil(loadedImage2)
    }

    // MARK: - SHA256 Hash Tests

    func testSHA256HashConsistency() {
        let input = "https://example.com/test.jpg"
        let hash1 = ImageDiskCache.sha256Hash(for: input)
        let hash2 = ImageDiskCache.sha256Hash(for: input)

        XCTAssertEqual(hash1, hash2)
        XCTAssertEqual(hash1.count, 64) // SHA256 produces 64 hex characters
    }

    func testSHA256HashDifferentInputs() {
        let hash1 = ImageDiskCache.sha256Hash(for: "input1")
        let hash2 = ImageDiskCache.sha256Hash(for: "input2")

        XCTAssertNotEqual(hash1, hash2)
    }

    // MARK: - Directory Tests

    func testCacheDirectoryExists() async {
        let directory = await diskCache.cacheDirectory
        XCTAssertNotNil(directory)
    }

    // MARK: - Insert Count Tests

    func testInsertCountIncrement() async {
        await diskCache.resetInsertCount()

        let url = createTestURL("insert-count-test")
        let image = createTestImage()

        await diskCache.saveImage(image, for: url)

        let count = await diskCache.currentInsertCount
        XCTAssertEqual(count, 1)
    }

    // MARK: - Disabled Disk Cache Tests

    func testDisabledDiskCache() async {
        let config = ImageCacheConfiguration(diskCacheEnabled: false)
        let disabledCache = ImageDiskCache(configuration: config)

        let url = createTestURL("disabled-test")
        let image = createTestImage()

        await disabledCache.saveImage(image, for: url)
        let loadedImage = await disabledCache.loadImage(for: url)

        XCTAssertNil(loadedImage)
    }
}
