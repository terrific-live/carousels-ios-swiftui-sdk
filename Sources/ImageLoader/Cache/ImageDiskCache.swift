//
//  ImageDiskCache.swift
//  ImageLoader
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import CommonCrypto

// MARK: - ImageDiskCache Actor
/// Thread-safe disk cache operations using Swift Actor
public actor ImageDiskCache {

    // MARK: - Dependencies
    private let fileManager = FileManager.default

    // MARK: - Inputs
    private let directory: URL?
    private let configuration: ImageCacheConfiguration

    // MARK: - Init
    public init(configuration: ImageCacheConfiguration) {
        self.configuration = configuration

        // Setup directory
        if configuration.diskCacheEnabled {
            let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
            let dir = cacheDir?.appendingPathComponent("ImageCache", isDirectory: true)
            self.directory = dir

            // Create directory synchronously in init (nonisolated helper)
            if let dir {
                Self.createDirectoryIfNeeded(at: dir, using: fileManager)
            }
        } else {
            self.directory = nil
        }
    }

    // Cleanup tracking
    private var insertCount = 0
    private let cleanupInterval = 20

    // MARK: - Public Methods (Automatically Serialized by Actor)
    public func loadImage(for url: URL) -> PlatformImage? {
        guard let filePath = diskCachePath(for: url),
              fileManager.fileExists(atPath: filePath.path),
              let data = try? Data(contentsOf: filePath),
              let image = PlatformImage(data: data) else {
            return nil
        }

        // Update modification date for LRU tracking
        try? fileManager.setAttributes([.modificationDate: Date()], ofItemAtPath: filePath.path)

        return image
    }

    public func saveImage(_ image: PlatformImage, for url: URL) {
        guard let filePath = diskCachePath(for: url),
              let data = imageData(from: image) else {
            return
        }

        try? data.write(to: filePath)

        // Periodic cleanup (every 20 insertions)
        insertCount += 1
        if insertCount % cleanupInterval == 0 {
            performCleanup()
        }
    }

    public func removeImage(for url: URL) {
        guard let filePath = diskCachePath(for: url) else { return }
        try? fileManager.removeItem(at: filePath)
    }

    public func clearCache() {
        guard let directory else { return }
        try? fileManager.removeItem(at: directory)
        Self.createDirectoryIfNeeded(at: directory, using: fileManager)
    }

    public func performInitialCleanup() {
        performCleanup()
    }

    // MARK: - Test Helpers

    /// Returns the cache directory URL (for testing purposes)
    public var cacheDirectory: URL? {
        directory
    }

    /// Returns the current insert count (for testing purposes)
    public var currentInsertCount: Int {
        insertCount
    }

    /// Resets insert count (for testing purposes)
    public func resetInsertCount() {
        insertCount = 0
    }

    // MARK: - Private Helpers

    private func imageData(from image: PlatformImage) -> Data? {
        #if canImport(UIKit)
        return image.jpegData(compressionQuality: 0.8)
        #elseif canImport(AppKit)
        guard let tiffData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        return bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: 0.8])
        #endif
    }
}

// MARK: - Cleanup (Thread-Safe by Actor)
extension ImageDiskCache {
    func performCleanup() {
        cleanupOldImages()
        enforceDiskLimit()
    }

    private func cleanupOldImages() {
        guard let directory else { return }

        do {
            let files = try fileManager.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.contentModificationDateKey],
                options: [.skipsHiddenFiles]
            )

            let cutoffDate = Date().addingTimeInterval(-configuration.diskCacheAgeLimit)

            for fileURL in files {
                let attributes = try fileURL.resourceValues(forKeys: [.contentModificationDateKey])
                let modDate = attributes.contentModificationDate ?? Date.distantPast

                if modDate < cutoffDate {
                    try? fileManager.removeItem(at: fileURL)
                    logImageDiskCache("🗑️ Removed expired image - \(fileURL.lastPathComponent)")
                }
            }
        } catch {
            logImageDiskCache("❌ Failed to cleanup old images - \(error)")
        }
    }

    private func enforceDiskLimit() {
        guard let directory else { return }

        do {
            let files = try fileManager.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey],
                options: [.skipsHiddenFiles]
            )

            var totalSize: Int64 = 0
            var fileInfos: [(url: URL, date: Date, size: Int64)] = []

            for fileURL in files {
                let attributes = try fileURL.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey])
                let modDate = attributes.contentModificationDate ?? Date.distantPast
                let fileSize = Int64(attributes.fileSize ?? 0)

                totalSize += fileSize
                fileInfos.append((url: fileURL, date: modDate, size: fileSize))
            }

            if totalSize > configuration.diskCacheSizeLimit {
                fileInfos.sort { $0.date < $1.date }

                for fileInfo in fileInfos {
                    guard totalSize > configuration.diskCacheSizeLimit else { break }

                    try? fileManager.removeItem(at: fileInfo.url)
                    totalSize -= fileInfo.size
                    logImageDiskCache("🗑️ Removed old file - \(fileInfo.url.lastPathComponent)")
                }
            }
        } catch {
            logImageDiskCache("❌ Failed to enforce disk limit - \(error)")
        }
    }
}

// MARK: - Helpers
extension ImageDiskCache {
    /// Nonisolated static helper for creating directory - safe to call from init
    nonisolated static func createDirectoryIfNeeded(at directory: URL, using fileManager: FileManager) {
        if !fileManager.fileExists(atPath: directory.path) {
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
    }

    private func diskCachePath(for url: URL) -> URL? {
        guard let directory else { return nil }
        let fileName = Self.sha256Hash(for: url.absoluteString)
        return directory.appendingPathComponent(fileName)
    }

    /// Nonisolated static helper for SHA256 hashing - avoids actor isolation issues
    public nonisolated static func sha256Hash(for string: String) -> String {
        let data = Data(string.utf8)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))

        data.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(buffer.count), &hash)
        }

        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
