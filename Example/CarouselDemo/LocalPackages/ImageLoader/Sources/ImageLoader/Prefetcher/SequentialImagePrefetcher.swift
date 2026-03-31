//
//  SequentialImagePrefetcher.swift
//  ImageLoader
//

import Foundation

// MARK: - SequentialImagePrefetcher
/// Specialized prefetcher that prefetches +3 images from current selection
@MainActor
public final class SequentialImagePrefetcher {

    // MARK: - Configuration
    private static let prefetchCount = 3

    // MARK: - Properties
    private let prefetcher: ImagePrefetcherProtocol
    private var lastPrefetchedIndex: Int = -1

    // MARK: - Init
    public init(prefetcher: ImagePrefetcherProtocol = ImagePrefetcher.shared) {
        self.prefetcher = prefetcher
    }

    // MARK: - Public Methods

    /// Call this when the current page/selection changes
    /// - Parameters:
    ///   - currentIndex: The currently visible item index
    ///   - items: All items with image URLs
    public func onSelectionChanged<T: HasImageURL>(currentIndex: Int, items: [T]) {
        // Avoid redundant prefetching
        guard currentIndex != lastPrefetchedIndex else { return }
        lastPrefetchedIndex = currentIndex

        // Calculate the range of items to prefetch (+3 ahead)
        let startIndex = currentIndex + 1
        let endIndex = min(startIndex + Self.prefetchCount, items.count)

        guard startIndex < items.count else { return }

        // Get URLs for items to prefetch
        let urlsToPrefetch = items[startIndex..<endIndex]
            .compactMap { $0.imageURL }

        // Fire-and-forget prefetch (actor call)
        Task {
            await prefetcher.prefetch(urls: urlsToPrefetch)
        }
    }

    /// Call this when the current page/selection changes (with URL strings)
    public func onSelectionChanged(currentIndex: Int, imageURLStrings: [String]) {
        // Avoid redundant prefetching
        guard currentIndex != lastPrefetchedIndex else { return }
        lastPrefetchedIndex = currentIndex

        // Calculate the range of items to prefetch (+3 ahead)
        let startIndex = currentIndex + 1
        let endIndex = min(startIndex + Self.prefetchCount, imageURLStrings.count)

        guard startIndex < imageURLStrings.count else { return }

        // Get URLs for items to prefetch
        let urlsToPrefetch = Array(imageURLStrings[startIndex..<endIndex])

        // Fire-and-forget prefetch (actor call)
        Task {
            await prefetcher.prefetch(urlStrings: urlsToPrefetch)
        }
    }

    /// Cancel all prefetching
    public func cancelAll() {
        Task {
            await prefetcher.cancelAllPrefetching()
        }
        lastPrefetchedIndex = -1
    }

    // MARK: - Test Helpers

    /// Returns the last prefetched index (for testing)
    public var currentLastPrefetchedIndex: Int {
        lastPrefetchedIndex
    }

    /// Reset the last prefetched index (for testing)
    public func reset() {
        lastPrefetchedIndex = -1
    }
}
