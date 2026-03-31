//
//  ImagePrefetcher.swift
//  ImageLoader
//

import Foundation

// MARK: - ImagePrefetcher
/// Prefetches images in the background for smoother scrolling experience.
/// Uses an actor for thread-safe task management.
public actor ImagePrefetcher: ImagePrefetcherProtocol {

    // MARK: - Singleton
    public nonisolated static let shared = ImagePrefetcher()

    // MARK: - Properties
    private let imageLoader: ImageLoaderProtocol
    private var prefetchTasks: [URL: Task<Void, Never>] = [:]
    private let maxConcurrentPrefetches: Int

    // MARK: - Init
    public init(
        imageLoader: ImageLoaderProtocol = ImageLoader.shared,
        maxConcurrentPrefetches: Int = 3
    ) {
        self.imageLoader = imageLoader
        self.maxConcurrentPrefetches = maxConcurrentPrefetches
    }

    // MARK: - ImagePrefetcherProtocol

    public func prefetch(urls: [URL]) {
        let urlsToFetch = urls.prefix(maxConcurrentPrefetches)
        for url in urlsToFetch {
            prefetchImage(at: url)
        }
    }

    public func prefetch(urlStrings: [String]) {
        let urls = urlStrings.compactMap { URL(string: $0) }
        prefetch(urls: urls)
    }

    public func cancelPrefetching(for urls: [URL]) {
        for url in urls {
            prefetchTasks[url]?.cancel()
            prefetchTasks.removeValue(forKey: url)
        }
    }

    public func cancelAllPrefetching() {
        prefetchTasks.values.forEach { $0.cancel() }
        prefetchTasks.removeAll()
    }

    // MARK: - Test Helpers

    /// Returns the number of active prefetch tasks
    public var activePrefetchCount: Int {
        prefetchTasks.count
    }

    /// Check if prefetching is active for a URL
    public func isPrefetching(url: URL) -> Bool {
        prefetchTasks[url] != nil
    }

    // MARK: - Private Methods

    private func prefetchImage(at url: URL) {
        // Skip if already prefetching this URL
        guard prefetchTasks[url] == nil else { return }

        let task = Task(priority: .low) { [weak self] in
            _ = await self?.imageLoader.loadImage(from: url)
            await self?.removeTask(for: url)
        }

        prefetchTasks[url] = task
    }

    private func removeTask(for url: URL) {
        prefetchTasks.removeValue(forKey: url)
    }
}
