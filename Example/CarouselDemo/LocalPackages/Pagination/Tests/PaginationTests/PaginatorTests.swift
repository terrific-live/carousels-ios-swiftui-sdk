//
//  PaginatorTests.swift
//  Pagination
//

import XCTest
@testable import Pagination

@MainActor
final class PaginatorTests: XCTestCase {

    // MARK: - Initial State

    func testInitialState() {
        let paginator = Paginator<String>(itemsPerPage: 10)

        XCTAssertTrue(paginator.items.isEmpty)
        XCTAssertFalse(paginator.isLoading)
        XCTAssertTrue(paginator.hasMorePages)
        XCTAssertNil(paginator.lastError)
    }

    // MARK: - Load Next Page (Happy Path)

    func testLoadNextPage_Success_AppendsItemsAndUpdatesState() async throws {
        let paginator = Paginator<String>(itemsPerPage: 10)

        try await paginator.loadNextPage { page, itemsPerPage in
            XCTAssertEqual(page, 1, "First load should request page 1")
            XCTAssertEqual(itemsPerPage, 10)
            return ["item1", "item2", "item3"]
        }

        XCTAssertEqual(paginator.items, ["item1", "item2", "item3"])
        XCTAssertFalse(paginator.isLoading)
        XCTAssertTrue(paginator.hasMorePages)
        XCTAssertNil(paginator.lastError)
    }

    func testLoadNextPage_MultipleCalls_AccumulatesItems() async throws {
        let paginator = Paginator<String>(itemsPerPage: 2)

        // Load page 1
        try await paginator.loadNextPage { page, _ in
            XCTAssertEqual(page, 1)
            return ["page1-a", "page1-b"]
        }

        // Load page 2
        try await paginator.loadNextPage { page, _ in
            XCTAssertEqual(page, 2)
            return ["page2-a", "page2-b"]
        }

        // Items should accumulate, not replace
        XCTAssertEqual(paginator.items.count, 4)
        XCTAssertEqual(paginator.items, ["page1-a", "page1-b", "page2-a", "page2-b"])
    }

    func testLoadNextPage_EmptyResponse_SetsHasMorePagesToFalse() async throws {
        let paginator = Paginator<String>(itemsPerPage: 10)
        XCTAssertTrue(paginator.hasMorePages)

        try await paginator.loadNextPage { _, _ in
            return [] // Server returns no items
        }

        XCTAssertFalse(paginator.hasMorePages, "Empty response should indicate no more pages")
        XCTAssertTrue(paginator.items.isEmpty)
    }

    // MARK: - Load Next Page (Error Handling)

    func testLoadNextPage_LoaderThrows_SetsLastError() async {
        let paginator = Paginator<String>(
            configuration: PaginatorConfiguration(
                itemsPerPage: 10,
                maxRetryAttempts: 0 // No retries for this test
            )
        )

        do {
            try await paginator.loadNextPage { _, _ in
                throw URLError(.badServerResponse)
            }
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertNotNil(paginator.lastError)
            XCTAssertFalse(paginator.isLoading)
            XCTAssertTrue(paginator.hasMorePages, "Should still allow retry")
        }
    }

    func testLoadNextPage_RetriesBeforeFailing() async {
        var attemptCount = 0
        let paginator = Paginator<String>(
            configuration: PaginatorConfiguration(
                itemsPerPage: 10,
                maxRetryAttempts: 2,
                retryBaseDelay: 0.01, // Fast retries for testing
                maxRetryDelay: 0.01
            )
        )

        do {
            try await paginator.loadNextPage { _, _ in
                attemptCount += 1
                throw URLError(.badServerResponse)
            }
            XCTFail("Should have thrown")
        } catch {
            // 1 initial attempt + 2 retries = 3 total
            XCTAssertEqual(attemptCount, 3)
        }
    }

    func testLoadNextPage_RetrySucceedsOnSecondAttempt_LoadsItems() async throws {
        var attemptCount = 0
        let paginator = Paginator<String>(
            configuration: PaginatorConfiguration(
                itemsPerPage: 10,
                maxRetryAttempts: 2,
                retryBaseDelay: 0.01,
                maxRetryDelay: 0.01
            )
        )

        try await paginator.loadNextPage { _, _ in
            attemptCount += 1
            if attemptCount < 2 {
                throw URLError(.badServerResponse)
            }
            return ["success"]
        }

        XCTAssertEqual(attemptCount, 2, "Should succeed on second attempt")
        XCTAssertEqual(paginator.items, ["success"])
        XCTAssertNil(paginator.lastError)
    }

    func testLoadNextPage_MaxRetriesExceeded_ThrowsPaginatorError() async {
        let paginator = Paginator<String>(
            configuration: PaginatorConfiguration(
                itemsPerPage: 10,
                maxRetryAttempts: 1,
                retryBaseDelay: 0.01,
                maxRetryDelay: 0.01
            )
        )

        do {
            try await paginator.loadNextPage { _, _ in
                throw URLError(.badServerResponse)
            }
            XCTFail("Should have thrown")
        } catch let error as PaginatorError {
            if case .maxRetriesExceeded(let attempts, _) = error {
                XCTAssertEqual(attempts, 2) // 1 initial + 1 retry
            } else {
                XCTFail("Expected maxRetriesExceeded error")
            }
        } catch {
            XCTFail("Expected PaginatorError, got \(error)")
        }
    }

    // MARK: - Load Next Page (Guards)

    func testLoadNextPage_WhenNoMorePages_ReturnsEarly() async throws {
        let paginator = Paginator<String>(itemsPerPage: 10)

        // First load returns empty (no more pages)
        try await paginator.loadNextPage { _, _ in [] }
        XCTAssertFalse(paginator.hasMorePages)

        // Second load should not call loader
        var loaderCalled = false
        try await paginator.loadNextPage { _, _ in
            loaderCalled = true
            return ["should not appear"]
        }

        XCTAssertFalse(loaderCalled, "Loader should not be called when no more pages")
        XCTAssertTrue(paginator.items.isEmpty)
    }

    // MARK: - Should Load Next Page

    func testShouldLoadNextPage_WhenNearEnd_ReturnsTrue() async throws {
        let paginator = Paginator<String>(itemsPerPage: 10, prefetchOffset: 3)

        try await paginator.loadNextPage { _, _ in
            return Array(repeating: "item", count: 10)
        }

        // At index 6, remaining = 10 - 6 - 1 = 3, which equals prefetchOffset
        XCTAssertTrue(paginator.shouldLoadNextPage(for: 6))

        // At index 7, remaining = 10 - 7 - 1 = 2, less than prefetchOffset
        XCTAssertTrue(paginator.shouldLoadNextPage(for: 7))
    }

    func testShouldLoadNextPage_WhenNotNearEnd_ReturnsFalse() async throws {
        let paginator = Paginator<String>(itemsPerPage: 10, prefetchOffset: 3)

        try await paginator.loadNextPage { _, _ in
            return Array(repeating: "item", count: 10)
        }

        // At index 0, remaining = 10 - 0 - 1 = 9, greater than prefetchOffset(3)
        XCTAssertFalse(paginator.shouldLoadNextPage(for: 0))

        // At index 5, remaining = 10 - 5 - 1 = 4, greater than prefetchOffset(3)
        XCTAssertFalse(paginator.shouldLoadNextPage(for: 5))
    }

    func testShouldLoadNextPage_WhenNoMorePages_ReturnsFalse() async throws {
        let paginator = Paginator<String>(itemsPerPage: 10, prefetchOffset: 3)

        // Load empty page to set hasMorePages = false
        try await paginator.loadNextPage { _, _ in [] }

        XCTAssertFalse(paginator.shouldLoadNextPage(for: 0))
    }

    func testShouldLoadNextPage_WhenEmpty_ReturnsTrue() {
        let paginator = Paginator<String>(itemsPerPage: 10, prefetchOffset: 3)

        // Empty list, at index 0: remaining = 0 - 0 - 1 = -1, less than prefetchOffset
        XCTAssertTrue(paginator.shouldLoadNextPage(for: 0))
    }

    // MARK: - Reset

    func testReset_ClearsAllState() async throws {
        let paginator = Paginator<String>(itemsPerPage: 10)

        // Load some data and create some state
        try await paginator.loadNextPage { _, _ in ["item1", "item2"] }
        XCTAssertFalse(paginator.items.isEmpty)

        // Reset
        paginator.reset()

        // Verify all state is cleared
        XCTAssertTrue(paginator.items.isEmpty)
        XCTAssertTrue(paginator.hasMorePages)
        XCTAssertFalse(paginator.isLoading)
        XCTAssertNil(paginator.lastError)
    }

    func testReset_AllowsLoadingFromPageOneAgain() async throws {
        let paginator = Paginator<String>(itemsPerPage: 10)

        // Load page 1
        try await paginator.loadNextPage { page, _ in
            return ["first-load-page-\(page)"]
        }
        XCTAssertEqual(paginator.items.first, "first-load-page-1")

        // Reset and load again
        paginator.reset()

        try await paginator.loadNextPage { page, _ in
            return ["second-load-page-\(page)"]
        }

        // Should start from page 1 again
        XCTAssertEqual(paginator.items, ["second-load-page-1"])
    }

    // MARK: - Retry Last Failed Page

    func testRetryLastFailedPage_WhenNoError_DoesNothing() async throws {
        let paginator = Paginator<String>(itemsPerPage: 10)

        // No error state - retry should do nothing
        var loaderCalled = false
        try await paginator.retryLastFailedPage { _, _ in
            loaderCalled = true
            return ["item"]
        }

        XCTAssertFalse(loaderCalled)
        XCTAssertTrue(paginator.items.isEmpty)
    }

    func testRetryLastFailedPage_AfterError_RetriesSuccessfully() async throws {
        var shouldFail = true
        let paginator = Paginator<String>(
            configuration: PaginatorConfiguration(
                itemsPerPage: 10,
                maxRetryAttempts: 0
            )
        )

        // First attempt fails
        do {
            try await paginator.loadNextPage { _, _ in
                if shouldFail {
                    throw URLError(.badServerResponse)
                }
                return ["item"]
            }
        } catch {
            XCTAssertNotNil(paginator.lastError)
        }

        // Retry after fixing the "server"
        shouldFail = false
        try await paginator.retryLastFailedPage { _, _ in
            return ["retry-success"]
        }

        XCTAssertEqual(paginator.items, ["retry-success"])
        XCTAssertNil(paginator.lastError)
    }

    // MARK: - Configuration

    func testConfiguration_DefaultValues() {
        let config = PaginatorConfiguration(itemsPerPage: 10)

        XCTAssertEqual(config.itemsPerPage, 10)
        XCTAssertEqual(config.prefetchOffset, 4)
        XCTAssertEqual(config.maxRetryAttempts, 3)
        XCTAssertEqual(config.retryBaseDelay, 1.0)
        XCTAssertEqual(config.maxRetryDelay, 8.0)
    }

    func testConfiguration_CustomValues() {
        let config = PaginatorConfiguration(
            itemsPerPage: 20,
            prefetchOffset: 5,
            maxRetryAttempts: 2,
            retryBaseDelay: 0.5,
            maxRetryDelay: 4.0
        )

        XCTAssertEqual(config.itemsPerPage, 20)
        XCTAssertEqual(config.prefetchOffset, 5)
        XCTAssertEqual(config.maxRetryAttempts, 2)
        XCTAssertEqual(config.retryBaseDelay, 0.5)
        XCTAssertEqual(config.maxRetryDelay, 4.0)
    }
}
