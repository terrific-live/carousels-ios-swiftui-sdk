//
//  ImageLoader.swift
//  ImageLoader
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - ImageLoader
/// Actor-based async image loader with caching support.
/// Using an actor ensures thread-safe access to activeTasks dictionary
/// without manual lock management and handles suspension points correctly.
public actor ImageLoader: ImageLoaderProtocol {

    // MARK: - Singleton
    /// Accessible from any isolation context - actors are Sendable by definition
    public nonisolated static let shared = ImageLoader()

    // MARK: - Properties
    private let cache: ImageCacheProtocol
    private let urlSession: URLSession
    private let configuration: ImageLoaderConfiguration

    /// Active download tasks keyed by URL.
    /// Actor isolation guarantees thread-safe access.
    private var activeTasks: [URL: Task<PlatformImage?, Never>] = [:]

    // MARK: - Init
    public init(
        cache: ImageCacheProtocol = ImageCache.shared,
        configuration: ImageLoaderConfiguration = .default
    ) {
        self.cache = cache
        self.configuration = configuration

        let sessionConfig = URLSessionConfiguration.default
        // We use ImageCache for caching; bypass URLSession's native cache
        sessionConfig.requestCachePolicy = .reloadIgnoringLocalCacheData
        sessionConfig.urlCache = nil
        // Set URLSession timeout as backup (our timeout will typically trigger first)
        sessionConfig.timeoutIntervalForRequest = configuration.downloadTimeout + 5
        sessionConfig.timeoutIntervalForResource = configuration.downloadTimeout + 10

        self.urlSession = URLSession(configuration: sessionConfig)
    }

    // MARK: - ImageLoaderProtocol

    public func loadImage(from url: URL) async -> PlatformImage? {
        // Check cache first
        if let cachedImage = await cache.image(for: url) {
            return cachedImage
        }

        // Get or create task atomically (no suspension point in getOrCreateTask)
        let task = getOrCreateTask(for: url)

        // Await the task - actor may process other calls during this suspension
        return await task.value
    }

    public func loadImage(from urlString: String) async -> PlatformImage? {
        guard let url = URL(string: urlString) else { return nil }
        return await loadImage(from: url)
    }

    public func cancelLoad(for url: URL) {
        activeTasks[url]?.cancel()
        activeTasks.removeValue(forKey: url)
    }

    public func cancelAllLoads() {
        activeTasks.values.forEach { $0.cancel() }
        activeTasks.removeAll()
    }

    // MARK: - Test Helpers

    /// Returns the number of active tasks (for testing)
    public var activeTaskCount: Int {
        activeTasks.count
    }

    /// Check if a task is active for the given URL (for testing)
    public func hasActiveTask(for url: URL) -> Bool {
        activeTasks[url] != nil
    }

    // MARK: - Private Methods

    /// Gets existing task or creates a new one atomically.
    /// This method has NO suspension points, so it executes atomically within the actor.
    /// This prevents reentrancy issues where another call could interleave.
    private func getOrCreateTask(for url: URL) -> Task<PlatformImage?, Never> {
        // If task already exists, return it (deduplication)
        if let existingTask = activeTasks[url] {
            return existingTask
        }

        // Create new task - capture url for cleanup
        let task = Task<PlatformImage?, Never> { [weak self] in
            guard let self else { return nil }

            let image = await self.downloadImage(from: url)

            // Cleanup: remove from active tasks when done
            await self.removeTask(for: url)

            return image
        }

        activeTasks[url] = task
        return task
    }

    /// Removes completed task from tracking dictionary.
    private func removeTask(for url: URL) {
        activeTasks.removeValue(forKey: url)
    }

    /// Downloads image from URL with timeout and retry logic.
    private func downloadImage(from url: URL) async -> PlatformImage? {
        var lastError: Error?

        for attempt in 0...configuration.maxRetryAttempts {
            if attempt > 0 {
                log("🔄 Retry attempt \(attempt) for \(url.lastPathComponent)")
            }

            do {
                let image = try await downloadWithTimeout(from: url)

                // Cache the image
                if let image {
                    await cache.insertImage(image, for: url)
                }

                return image
            } catch is CancellationError {
                log("⚠️ Download cancelled for \(url.lastPathComponent)")
                return nil
            } catch ImageLoaderError.timeout {
                log("⏱️ Timeout for \(url.lastPathComponent)")
                lastError = ImageLoaderError.timeout
                // Continue to retry
            } catch {
                log("❌ Error loading \(url.lastPathComponent): \(error.localizedDescription)")
                lastError = error
                // Don't retry on non-timeout errors
                break
            }
        }

        if let error = lastError as? ImageLoaderError, error == .timeout {
            log("❌ Failed after \(configuration.maxRetryAttempts) retries for \(url.lastPathComponent)")
        }
        return nil
    }

    /// Downloads with timeout using task race pattern.
    private func downloadWithTimeout(from url: URL) async throws -> PlatformImage? {
        let filename = url.lastPathComponent
        let timeout = configuration.downloadTimeout
        log("Starting download for \(filename) (timeout: \(timeout)s)")

        // Race between download and timeout
        return try await withThrowingTaskGroup(of: PlatformImage?.self) { group in
            // Download task
            group.addTask { [urlSession] in
                let (data, response) = try await urlSession.data(from: url)

                guard let httpResponse = response as? HTTPURLResponse else {
                    Self.log("❌ Invalid response type for \(filename)")
                    return nil
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    Self.log("❌ HTTP \(httpResponse.statusCode) for \(filename)")
                    return nil
                }

                guard let image = PlatformImage(data: data) else {
                    Self.log("❌ Failed to create image from data for \(filename)")
                    return nil
                }

                Self.log("✅ Successfully loaded \(filename)")
                return image
            }

            // Timeout task
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                throw ImageLoaderError.timeout
            }

            // Return first completed result, cancel the other
            guard let result = try await group.next() else {
                throw ImageLoaderError.timeout
            }

            // Cancel remaining tasks (the timeout or the download)
            group.cancelAll()

            return result
        }
    }

    /// Nonisolated logging - safe to call from task groups
    private nonisolated static func log(_ message: String) {
        logImageLoader(message)
    }

    private func log(_ message: String) {
        Self.log(message)
    }
}
