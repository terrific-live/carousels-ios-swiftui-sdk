//
//  ImageCache.swift
//  ImageLoader
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - ImageCache
/// In-memory image cache using NSCache with actor-based disk persistence.
/// Thread-safe: NSCache is thread-safe, disk operations use an actor.
/// @unchecked Sendable because NSCache is thread-safe but not marked Sendable.
public final class ImageCache: ImageCacheProtocol, @unchecked Sendable {

    // MARK: - Singleton
    public nonisolated static let shared = ImageCache()

    // MARK: - Properties
    private let memoryCache: NSCache<NSURL, PlatformImage>
    private let diskCache: ImageDiskCache
    private let configuration: ImageCacheConfiguration

    // MARK: - Init
    public init(configuration: ImageCacheConfiguration = .default) {
        self.configuration = configuration
        self.memoryCache = NSCache<NSURL, PlatformImage>()
        self.memoryCache.countLimit = configuration.memoryCountLimit
        self.memoryCache.totalCostLimit = configuration.memoryCostLimit

        self.diskCache = ImageDiskCache(configuration: configuration)

        // Initial cleanup (non-blocking)
        if configuration.diskCacheEnabled {
            Task.detached(priority: .utility) {
                await self.diskCache.performInitialCleanup()
            }
        }
    }

    // MARK: - ImageCacheProtocol
    public func image(for url: URL) async -> PlatformImage? {
        // Check memory cache first (synchronous, fast)
        if let cachedImage = memoryCache.object(forKey: url as NSURL) {
            return cachedImage
        }

        // Check disk cache (async, serialized by actor)
        if let diskImage = await diskCache.loadImage(for: url) {
            // Store in memory cache for faster subsequent access
            memoryCache.setObject(diskImage, forKey: url as NSURL, cost: diskImage.diskSize)
            return diskImage
        }

        return nil
    }

    public func insertImage(_ image: PlatformImage?, for url: URL) async {
        guard let image else {
            await removeImage(for: url)
            return
        }

        // Insert into memory cache
        memoryCache.setObject(image, forKey: url as NSURL, cost: image.diskSize)

        // Save to disk cache (serialized by actor - thread-safe)
        await diskCache.saveImage(image, for: url)
    }

    public func removeImage(for url: URL) async {
        memoryCache.removeObject(forKey: url as NSURL)
        await diskCache.removeImage(for: url)
    }

    public func removeAllImages() async {
        memoryCache.removeAllObjects()
        await diskCache.clearCache()
    }

    // MARK: - Test Helpers

    /// Check if image exists in memory cache only
    public func imageInMemoryCache(for url: URL) -> PlatformImage? {
        memoryCache.object(forKey: url as NSURL)
    }

    /// Check if image exists in disk cache only
    public func imageInDiskCache(for url: URL) async -> PlatformImage? {
        await diskCache.loadImage(for: url)
    }
}

// MARK: - PlatformImage Extension
extension PlatformImage {
    var diskSize: Int {
        #if canImport(UIKit)
        guard let cgImage else { return 0 }
        return cgImage.bytesPerRow * cgImage.height
        #elseif canImport(AppKit)
        guard let tiffData = tiffRepresentation else { return 0 }
        return tiffData.count
        #endif
    }
}
