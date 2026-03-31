//
//  SequentialImagePrefetcherTests.swift
//  ImageLoaderTests
//

import XCTest
@testable import ImageLoader

// MARK: - Test Item

struct TestImageItem: HasImageURL {
    let id: Int
    let imageURL: URL?

    init(id: Int) {
        self.id = id
        self.imageURL = URL(string: "https://example.com/image-\(id).jpg")
    }
}

// MARK: - Tests

@MainActor
final class SequentialImagePrefetcherTests: XCTestCase {

    var prefetcher: SequentialImagePrefetcher!
    var mockPrefetcher: MockImagePrefetcher!

    override func setUp() async throws {
        mockPrefetcher = MockImagePrefetcher()
        prefetcher = SequentialImagePrefetcher(prefetcher: mockPrefetcher)
    }

    override func tearDown() async throws {
        prefetcher.cancelAll()
        await mockPrefetcher.reset()
        prefetcher = nil
        mockPrefetcher = nil
    }

    // MARK: - Initial State Tests

    func testInitialLastPrefetchedIndex() {
        XCTAssertEqual(prefetcher.currentLastPrefetchedIndex, -1)
    }

    // MARK: - Selection Changed Tests (HasImageURL)

    func testOnSelectionChangedPrefetchesNextThreeImages() async throws {
        let items = (0..<10).map { TestImageItem(id: $0) }

        prefetcher.onSelectionChanged(currentIndex: 0, items: items)

        // Wait for async prefetch
        try await Task.sleep(nanoseconds: 100_000_000)

        let prefetchedURLs = await mockPrefetcher.prefetchedURLs
        XCTAssertEqual(prefetchedURLs.count, 3)

        // Should prefetch items 1, 2, 3 (next 3 after index 0)
        for i in 1...3 {
            XCTAssertTrue(prefetchedURLs.contains(items[i].imageURL!))
        }
    }

    func testOnSelectionChangedUpdatesLastPrefetchedIndex() {
        let items = (0..<10).map { TestImageItem(id: $0) }

        prefetcher.onSelectionChanged(currentIndex: 5, items: items)

        XCTAssertEqual(prefetcher.currentLastPrefetchedIndex, 5)
    }

    func testOnSelectionChangedSkipsRedundantPrefetch() async throws {
        let items = (0..<10).map { TestImageItem(id: $0) }

        prefetcher.onSelectionChanged(currentIndex: 3, items: items)
        prefetcher.onSelectionChanged(currentIndex: 3, items: items) // Same index

        // Wait for async prefetch
        try await Task.sleep(nanoseconds: 100_000_000)

        let prefetchedURLs = await mockPrefetcher.prefetchedURLs
        // Should only prefetch once (3 URLs)
        XCTAssertEqual(prefetchedURLs.count, 3)
    }

    func testOnSelectionChangedNearEnd() async throws {
        let items = (0..<5).map { TestImageItem(id: $0) }

        prefetcher.onSelectionChanged(currentIndex: 3, items: items)

        // Wait for async prefetch
        try await Task.sleep(nanoseconds: 100_000_000)

        let prefetchedURLs = await mockPrefetcher.prefetchedURLs
        // Only 1 item left to prefetch (index 4)
        XCTAssertEqual(prefetchedURLs.count, 1)
    }

    func testOnSelectionChangedAtEnd() async throws {
        let items = (0..<5).map { TestImageItem(id: $0) }

        prefetcher.onSelectionChanged(currentIndex: 4, items: items)

        // Wait for async prefetch
        try await Task.sleep(nanoseconds: 100_000_000)

        let prefetchedURLs = await mockPrefetcher.prefetchedURLs
        // No items left to prefetch
        XCTAssertEqual(prefetchedURLs.count, 0)
    }

    // MARK: - Selection Changed Tests (URL Strings)

    func testOnSelectionChangedWithURLStrings() async throws {
        let urlStrings = (0..<10).map { "https://example.com/image-\($0).jpg" }

        prefetcher.onSelectionChanged(currentIndex: 2, imageURLStrings: urlStrings)

        // Wait for async prefetch
        try await Task.sleep(nanoseconds: 100_000_000)

        let prefetchedStrings = await mockPrefetcher.prefetchedURLStrings
        XCTAssertEqual(prefetchedStrings.count, 3)

        // Should prefetch strings at indices 3, 4, 5
        for i in 3...5 {
            XCTAssertTrue(prefetchedStrings.contains(urlStrings[i]))
        }
    }

    // MARK: - Cancel Tests

    func testCancelAllResetsPrefetcher() async throws {
        let items = (0..<10).map { TestImageItem(id: $0) }

        prefetcher.onSelectionChanged(currentIndex: 3, items: items)
        prefetcher.cancelAll()

        // Wait for async operations
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(prefetcher.currentLastPrefetchedIndex, -1)

        let allCancelled = await mockPrefetcher.allCancelled
        XCTAssertTrue(allCancelled)
    }

    // MARK: - Reset Tests

    func testReset() {
        let items = (0..<10).map { TestImageItem(id: $0) }

        prefetcher.onSelectionChanged(currentIndex: 5, items: items)
        prefetcher.reset()

        XCTAssertEqual(prefetcher.currentLastPrefetchedIndex, -1)
    }

    // MARK: - Empty Items Tests

    func testOnSelectionChangedWithEmptyItems() async throws {
        let items: [TestImageItem] = []

        prefetcher.onSelectionChanged(currentIndex: 0, items: items)

        // Wait for async prefetch
        try await Task.sleep(nanoseconds: 100_000_000)

        let prefetchedURLs = await mockPrefetcher.prefetchedURLs
        XCTAssertEqual(prefetchedURLs.count, 0)
    }

    // MARK: - Default Initializer Tests

    func testDefaultInitializer() {
        let defaultPrefetcher = SequentialImagePrefetcher()
        XCTAssertNotNil(defaultPrefetcher)
        XCTAssertEqual(defaultPrefetcher.currentLastPrefetchedIndex, -1)
    }
}
