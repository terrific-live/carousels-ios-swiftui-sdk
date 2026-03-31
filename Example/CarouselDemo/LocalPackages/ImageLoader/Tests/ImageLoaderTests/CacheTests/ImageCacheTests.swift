//
//  ImageCacheTests.swift
//  ImageLoaderTests
//

import XCTest
@testable import ImageLoader

final class ImageCacheTests: XCTestCase {

    var cache: ImageCache!

    override func setUp() async throws {
        cache = ImageCache(configuration: .testing)
        await cache.removeAllImages()
    }

    override func tearDown() async throws {
        await cache.removeAllImages()
        cache = nil
    }

    // MARK: - Insert and Retrieve Tests

    func testInsertAndRetrieveImage() async {
        let url = createTestURL("cache-test")
        let image = createTestImage()

        await cache.insertImage(image, for: url)
        let retrievedImage = await cache.image(for: url)

        XCTAssertNotNil(retrievedImage)
    }

    func testRetrieveNonExistentImage() async {
        let url = createTestURL("non-existent")
        let retrievedImage = await cache.image(for: url)

        XCTAssertNil(retrievedImage)
    }

    // MARK: - Memory Cache Tests

    func testImageInMemoryCache() async {
        let url = createTestURL("memory-cache-test")
        let image = createTestImage()

        await cache.insertImage(image, for: url)
        let memoryImage = cache.imageInMemoryCache(for: url)

        XCTAssertNotNil(memoryImage)
    }

    func testImageNotInMemoryCacheInitially() {
        let url = createTestURL("not-in-memory")
        let memoryImage = cache.imageInMemoryCache(for: url)

        XCTAssertNil(memoryImage)
    }

    // MARK: - Disk Cache Tests

    func testImageInDiskCache() async {
        let url = createTestURL("disk-cache-test")
        let image = createTestImage()

        await cache.insertImage(image, for: url)
        let diskImage = await cache.imageInDiskCache(for: url)

        XCTAssertNotNil(diskImage)
    }

    // MARK: - Remove Tests

    func testRemoveImage() async {
        let url = createTestURL("remove-test")
        let image = createTestImage()

        await cache.insertImage(image, for: url)
        await cache.removeImage(for: url)

        let retrievedImage = await cache.image(for: url)
        XCTAssertNil(retrievedImage)
    }

    // MARK: - Remove All Tests

    func testRemoveAllImages() async {
        let url1 = createTestURL("remove-all-1")
        let url2 = createTestURL("remove-all-2")
        let image = createTestImage()

        await cache.insertImage(image, for: url1)
        await cache.insertImage(image, for: url2)
        await cache.removeAllImages()

        let image1 = await cache.image(for: url1)
        let image2 = await cache.image(for: url2)

        XCTAssertNil(image1)
        XCTAssertNil(image2)
    }

    // MARK: - Insert Nil Tests

    func testInsertNilRemovesImage() async {
        let url = createTestURL("insert-nil-test")
        let image = createTestImage()

        await cache.insertImage(image, for: url)
        await cache.insertImage(nil, for: url)

        let retrievedImage = await cache.image(for: url)
        XCTAssertNil(retrievedImage)
    }

    // MARK: - Multiple URLs Tests

    func testMultipleImages() async {
        let urls = (0..<5).map { createTestURL("multi-\($0)") }
        let image = createTestImage()

        for url in urls {
            await cache.insertImage(image, for: url)
        }

        for url in urls {
            let retrievedImage = await cache.image(for: url)
            XCTAssertNotNil(retrievedImage, "Expected image for \(url)")
        }
    }

    // MARK: - Shared Instance Tests

    func testSharedInstanceExists() {
        let shared = ImageCache.shared
        XCTAssertNotNil(shared)
    }

    // MARK: - Memory Only Configuration Tests

    func testMemoryOnlyCache() async {
        let memoryOnlyCache = ImageCache(configuration: .memoryOnly)
        let url = createTestURL("memory-only-test")
        let image = createTestImage()

        await memoryOnlyCache.insertImage(image, for: url)

        // Should still work for memory cache
        let memoryImage = memoryOnlyCache.imageInMemoryCache(for: url)
        XCTAssertNotNil(memoryImage)
    }
}
