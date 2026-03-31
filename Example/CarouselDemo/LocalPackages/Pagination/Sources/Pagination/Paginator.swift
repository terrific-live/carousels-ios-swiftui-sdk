//
//  Paginator.swift
//  Pagination
//

import Foundation

// MARK: - Configuration
public struct PaginatorConfiguration: Sendable {
    /// Number of items per page
    public let itemsPerPage: Int

    /// Start loading next page when this many items remain
    public let prefetchOffset: Int

    /// Maximum retry attempts on failure
    public let maxRetryAttempts: Int

    /// Base delay for exponential backoff (seconds)
    public let retryBaseDelay: TimeInterval

    /// Maximum delay between retries (seconds)
    public let maxRetryDelay: TimeInterval

    public init(
        itemsPerPage: Int,
        prefetchOffset: Int = 4,
        maxRetryAttempts: Int = 3,
        retryBaseDelay: TimeInterval = 1.0,
        maxRetryDelay: TimeInterval = 8.0
    ) {
        precondition(itemsPerPage > 0, "itemsPerPage must be positive")
        precondition(prefetchOffset >= 0, "prefetchOffset cannot be negative")
        precondition(maxRetryAttempts >= 0, "maxRetryAttempts cannot be negative")

        self.itemsPerPage = itemsPerPage
        self.prefetchOffset = prefetchOffset
        self.maxRetryAttempts = maxRetryAttempts
        self.retryBaseDelay = retryBaseDelay
        self.maxRetryDelay = maxRetryDelay
    }
}

// MARK: - Errors
public enum PaginatorError: Error, LocalizedError, Equatable, Sendable {
    case alreadyLoading
    case noMorePages
    case loadFailed(underlyingError: String)
    case maxRetriesExceeded(attempts: Int, lastError: String)

    public var errorDescription: String? {
        switch self {
        case .alreadyLoading:
            return "A page load is already in progress"
        case .noMorePages:
            return "No more pages to load"
        case .loadFailed(let error):
            return "Failed to load page: \(error)"
        case .maxRetriesExceeded(let attempts, let lastError):
            return "Failed after \(attempts) attempts. Last error: \(lastError)"
        }
    }
}

// MARK: - Paginator
@MainActor
public final class Paginator<Item> {

    // MARK: - Public State
    public private(set) var items: [Item] = []
    public private(set) var isLoading: Bool = false
    public private(set) var hasMorePages: Bool = true

    /// Controls whether pagination is enabled. When false, only first page loads.
    /// Can be toggled at runtime to enable/disable pagination behavior.
    public var paginationEnabled: Bool = true

    /// Last error encountered during pagination (nil if last load succeeded)
    public private(set) var lastError: Error?

    // MARK: - Configuration
    public let configuration: PaginatorConfiguration

    // MARK: - Internal State
    private var currentPage: Int = 0
    private var currentRetryCount: Int = 0

    // MARK: - Init
    public init(configuration: PaginatorConfiguration) {
        self.configuration = configuration
    }

    /// Convenience initializer with default configuration
    public init(
        itemsPerPage: Int,
        prefetchOffset: Int = 4
    ) {
        self.configuration = PaginatorConfiguration(
            itemsPerPage: itemsPerPage,
            prefetchOffset: prefetchOffset
        )
    }
}

// MARK: - Public API
public extension Paginator {

    func reset() {
        currentPage = 0
        items = []
        hasMorePages = true
        isLoading = false
        lastError = nil
        currentRetryCount = 0
    }

    func shouldLoadNextPage(for index: Int) -> Bool {
        guard paginationEnabled, hasMorePages, !isLoading else { return false }
        // Load when remaining items <= prefetchOffset
        let itemsRemaining = items.count - index - 1
        return itemsRemaining <= configuration.prefetchOffset
    }

    /// Load next page with automatic retry on failure
    func loadNextPage(
        loader: @escaping (_ page: Int, _ itemsPerPage: Int) async throws -> [Item]
    ) async throws {
        guard !isLoading else {
            log("⚠️ Already loading, skipping")
            return
        }

        guard hasMorePages else {
            log("⚠️ No more pages")
            return
        }

        isLoading = true
        lastError = nil
        currentRetryCount = 0

        let nextPage = currentPage + 1

        do {
            let newItems = try await loadWithRetry(page: nextPage, loader: loader)
            handleSuccess(newItems: newItems, page: nextPage)
        } catch {
            handleFailure(error: error, page: nextPage)
            throw error
        }
    }

    /// Retry loading the last failed page
    func retryLastFailedPage(
        loader: @escaping (_ page: Int, _ itemsPerPage: Int) async throws -> [Item]
    ) async throws {
        guard lastError != nil else {
            log("⚠️ No failed page to retry")
            return
        }

        guard !isLoading else {
            log("⚠️ Already loading, skipping retry")
            return
        }

        isLoading = true
        lastError = nil
        currentRetryCount = 0

        let nextPage = currentPage + 1

        do {
            let newItems = try await loadWithRetry(page: nextPage, loader: loader)
            handleSuccess(newItems: newItems, page: nextPage)
        } catch {
            handleFailure(error: error, page: nextPage)
            throw error
        }
    }
}

// MARK: - Private Implementation
private extension Paginator {

    func loadWithRetry(
        page: Int,
        loader: @escaping (_ page: Int, _ itemsPerPage: Int) async throws -> [Item]
    ) async throws -> [Item] {
        var lastAttemptError: Error?

        for attempt in 0...configuration.maxRetryAttempts {
            if attempt > 0 {
                let delay = calculateBackoffDelay(attempt: attempt)
                log("🔄 Retry \(attempt)/\(configuration.maxRetryAttempts) for page \(page) after \(String(format: "%.1f", delay))s")
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            } else {
                log("📄 Loading page \(page)...")
            }

            do {
                let newItems = try await loader(page, configuration.itemsPerPage)
                log("✅ Loaded page \(page): \(newItems.count) items")
                return newItems
            } catch is CancellationError {
                log("⚠️ Load cancelled for page \(page)")
                throw CancellationError()
            } catch {
                lastAttemptError = error
                log("❌ Attempt \(attempt + 1) failed for page \(page): \(error.localizedDescription)")

                // Don't retry on last attempt
                if attempt == configuration.maxRetryAttempts {
                    break
                }
            }
        }

        // All retries exhausted - include the last error for debugging
        let lastErrorDescription = lastAttemptError?.localizedDescription ?? "Unknown error"
        let finalError = PaginatorError.maxRetriesExceeded(
            attempts: configuration.maxRetryAttempts + 1,
            lastError: lastErrorDescription
        )
        log("❌ All retries exhausted for page \(page). Last error: \(lastErrorDescription)")
        throw finalError
    }

    func calculateBackoffDelay(attempt: Int) -> TimeInterval {
        // Exponential backoff: baseDelay * 2^(attempt-1)
        // attempt 1: 1s, attempt 2: 2s, attempt 3: 4s, etc.
        let delay = configuration.retryBaseDelay * pow(2.0, Double(attempt - 1))
        return min(delay, configuration.maxRetryDelay)
    }

    func handleSuccess(newItems: [Item], page: Int) {
        if newItems.isEmpty {
            hasMorePages = false
            log("📄 Page \(page) empty - no more pages")
        } else {
            currentPage = page
            items.append(contentsOf: newItems)
            log("📄 Page \(page) loaded. Total items: \(items.count)")

            // When pagination is disabled, stop after first page
            if !paginationEnabled {
                hasMorePages = false
                log("📄 Pagination disabled - no more pages will load")
            }
            // Partial page means we've reached the end
            else if newItems.count < configuration.itemsPerPage {
                hasMorePages = false
                log("📄 Page \(page) partial (\(newItems.count)/\(configuration.itemsPerPage)) - no more pages")
            }
        }
        isLoading = false
        lastError = nil
        currentRetryCount = 0
    }

    func handleFailure(error: Error, page: Int) {
        isLoading = false
        lastError = error
        log("❌ Failed to load page \(page): \(error.localizedDescription)")
    }

    func log(_ message: String) {
        logPagination(message)
    }
}
