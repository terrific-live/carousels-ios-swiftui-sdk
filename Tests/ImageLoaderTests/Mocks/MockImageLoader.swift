//
//  MockImageLoader.swift
//  ImageLoaderTests
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
@testable import ImageLoader

/// Mock image loader for testing
public actor MockImageLoader: ImageLoaderProtocol {
    public var loadedURLs: [URL] = []
    public var cancelledURLs: [URL] = []
    public var allCancelled = false
    public var imageToReturn: PlatformImage?
    public var shouldFail = false
    public var loadDelay: UInt64 = 0

    public init() {}

    public func loadImage(from url: URL) async -> PlatformImage? {
        loadedURLs.append(url)

        if loadDelay > 0 {
            try? await Task.sleep(nanoseconds: loadDelay)
        }

        if shouldFail {
            return nil
        }
        return imageToReturn ?? createTestImage()
    }

    public func loadImage(from urlString: String) async -> PlatformImage? {
        guard let url = URL(string: urlString) else { return nil }
        return await loadImage(from: url)
    }

    public func cancelLoad(for url: URL) {
        cancelledURLs.append(url)
    }

    public func cancelAllLoads() {
        allCancelled = true
    }

    public func reset() {
        loadedURLs = []
        cancelledURLs = []
        allCancelled = false
        imageToReturn = nil
        shouldFail = false
        loadDelay = 0
    }
}

/// Mock image cache for testing
public final class MockImageCache: ImageCacheProtocol, @unchecked Sendable {
    public var storedImages: [URL: PlatformImage] = [:]
    public var insertedURLs: [URL] = []
    public var removedURLs: [URL] = []
    public var clearedAll = false

    public init() {}

    public func image(for url: URL) async -> PlatformImage? {
        storedImages[url]
    }

    public func insertImage(_ image: PlatformImage?, for url: URL) async {
        if let image {
            storedImages[url] = image
            insertedURLs.append(url)
        } else {
            storedImages.removeValue(forKey: url)
        }
    }

    public func removeImage(for url: URL) async {
        storedImages.removeValue(forKey: url)
        removedURLs.append(url)
    }

    public func removeAllImages() async {
        storedImages.removeAll()
        clearedAll = true
    }

    public func reset() {
        storedImages.removeAll()
        insertedURLs.removeAll()
        removedURLs.removeAll()
        clearedAll = false
    }
}

/// Mock prefetcher for testing
public actor MockImagePrefetcher: ImagePrefetcherProtocol {
    public var prefetchedURLs: [URL] = []
    public var prefetchedURLStrings: [String] = []
    public var cancelledURLs: [URL] = []
    public var allCancelled = false

    public init() {}

    public func prefetch(urls: [URL]) {
        prefetchedURLs.append(contentsOf: urls)
    }

    public func prefetch(urlStrings: [String]) {
        prefetchedURLStrings.append(contentsOf: urlStrings)
    }

    public func cancelPrefetching(for urls: [URL]) {
        cancelledURLs.append(contentsOf: urls)
    }

    public func cancelAllPrefetching() {
        allCancelled = true
    }

    public func reset() {
        prefetchedURLs = []
        prefetchedURLStrings = []
        cancelledURLs = []
        allCancelled = false
    }
}

// MARK: - Test Helpers

func createTestImage(width: Int = 100, height: Int = 100) -> PlatformImage {
    #if canImport(UIKit)
    let size = CGSize(width: width, height: height)
    UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
    UIColor.red.setFill()
    UIRectFill(CGRect(origin: .zero, size: size))
    let image = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return image
    #elseif canImport(AppKit)
    let image = NSImage(size: NSSize(width: width, height: height))
    image.lockFocus()
    NSColor.red.setFill()
    NSRect(origin: .zero, size: NSSize(width: width, height: height)).fill()
    image.unlockFocus()
    return image
    #endif
}

func createTestURL(_ path: String = "test") -> URL {
    URL(string: "https://example.com/\(path).jpg")!
}
