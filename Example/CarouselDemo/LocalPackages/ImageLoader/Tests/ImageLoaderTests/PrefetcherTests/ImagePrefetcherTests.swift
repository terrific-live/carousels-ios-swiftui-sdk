//
//  ImagePrefetcherTests.swift
//  ImageLoaderTests
//

import XCTest
@testable import ImageLoader

final class ImagePrefetcherTests: XCTestCase {

    var prefetcher: ImagePrefetcher!
    var mockLoader: MockImageLoader!

    override func setUp() async throws {
        mockLoader = MockImageLoader()
        prefetcher = ImagePrefetcher(
            imageLoader: mockLoader,
            maxConcurrentPrefetches: 3
        )
    }

    override func tearDown() async throws {
        await prefetcher.cancelAllPrefetching()
        await mockLoader.reset()
        prefetcher = nil
        mockLoader = nil
    }

    // MARK: - Prefetch URLs Tests

    func testPrefetchURLs() async throws {
        let urls = [
            createTestURL("prefetch-1"),
            createTestURL("prefetch-2"),
            createTestURL("prefetch-3")
        ]

        await prefetcher.prefetch(urls: urls)

        // Wait for prefetch to complete
        try await Task.sleep(nanoseconds: 100_000_000)

        let loadedURLs = await mockLoader.loadedURLs
        XCTAssertEqual(loadedURLs.count, 3)
        for url in urls {
            XCTAssertTrue(loadedURLs.contains(url))
        }
    }

    func testPrefetchLimitsToMaxConcurrent() async {
        let urls = [
            createTestURL("limit-1"),
            createTestURL("limit-2"),
            createTestURL("limit-3"),
            createTestURL("limit-4"),
            createTestURL("limit-5")
        ]

        await prefetcher.prefetch(urls: urls)

        // Only first 3 should be prefetched (maxConcurrentPrefetches = 3)
        try? await Task.sleep(nanoseconds: 100_000_000)

        let loadedURLs = await mockLoader.loadedURLs
        XCTAssertEqual(loadedURLs.count, 3)
    }

    // MARK: - Prefetch URL Strings Tests

    func testPrefetchURLStrings() async throws {
        let urlStrings = [
            "https://example.com/string-1.jpg",
            "https://example.com/string-2.jpg"
        ]

        await prefetcher.prefetch(urlStrings: urlStrings)

        // Wait for prefetch to complete
        try await Task.sleep(nanoseconds: 100_000_000)

        let loadedURLs = await mockLoader.loadedURLs
        XCTAssertEqual(loadedURLs.count, 2)
    }

    func testPrefetchInvalidURLStringsAreIgnored() async throws {
        // Reset mock to ensure clean state
        await mockLoader.reset()

        let validURL1 = "https://example.com/invalid-test-valid1.jpg"
        let validURL2 = "https://example.com/invalid-test-valid2.jpg"
        let urlStrings = [
            validURL1,
            "not a valid url",  // This should be filtered out
            validURL2
        ]

        await prefetcher.prefetch(urlStrings: urlStrings)

        // Wait for prefetch to complete
        try await Task.sleep(nanoseconds: 100_000_000)

        let loadedURLs = await mockLoader.loadedURLs

        // Only valid URLs should be loaded
        XCTAssertTrue(loadedURLs.contains(URL(string: validURL1)!))
        XCTAssertTrue(loadedURLs.contains(URL(string: validURL2)!))

        // The invalid URL should not be loaded
        let invalidURLStrings = loadedURLs.map { $0.absoluteString }
        XCTAssertFalse(invalidURLStrings.contains { $0.contains("not a valid url") })
    }

    // MARK: - Cancel Tests

    func testCancelPrefetchingForURLs() async {
        let urls = [
            createTestURL("cancel-1"),
            createTestURL("cancel-2")
        ]

        await prefetcher.cancelPrefetching(for: urls)

        let count = await prefetcher.activePrefetchCount
        XCTAssertEqual(count, 0)
    }

    func testCancelAllPrefetching() async {
        await prefetcher.cancelAllPrefetching()

        let count = await prefetcher.activePrefetchCount
        XCTAssertEqual(count, 0)
    }

    // MARK: - Active Prefetch Tests

    func testActivePrefetchCount() async {
        let count = await prefetcher.activePrefetchCount
        XCTAssertEqual(count, 0)
    }

    func testIsPrefetching() async {
        let url = createTestURL("is-prefetching")

        let isPrefetching = await prefetcher.isPrefetching(url: url)
        XCTAssertFalse(isPrefetching)
    }

    // MARK: - Deduplication Tests

    func testDuplicateURLsAreNotPrefetchedTwice() async throws {
        let url = createTestURL("duplicate")

        // Set a delay so task stays active
        await mockLoader.setLoadDelay(500_000_000)

        await prefetcher.prefetch(urls: [url])
        await prefetcher.prefetch(urls: [url]) // Same URL again

        // Should only have one active prefetch
        let count = await prefetcher.activePrefetchCount
        XCTAssertEqual(count, 1)
    }

    // MARK: - Shared Instance Tests

    func testSharedInstanceExists() {
        let shared = ImagePrefetcher.shared
        XCTAssertNotNil(shared)
    }
}

// MARK: - MockImageLoader Helpers

private extension MockImageLoader {
    func setLoadDelay(_ delay: UInt64) async {
        loadDelay = delay
    }
}
