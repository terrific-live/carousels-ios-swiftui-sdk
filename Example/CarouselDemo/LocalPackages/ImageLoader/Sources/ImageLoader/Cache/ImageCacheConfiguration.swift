//
//  ImageCacheConfiguration.swift
//  ImageLoader
//

import Foundation

// MARK: - ImageCacheConfiguration
public struct ImageCacheConfiguration: Sendable {
    public let memoryCountLimit: Int
    public let memoryCostLimit: Int
    public let diskCacheEnabled: Bool
    public let diskCacheSizeLimit: Int64
    public let diskCacheAgeLimit: TimeInterval

    public init(
        memoryCountLimit: Int = 100,
        memoryCostLimit: Int = 50 * 1024 * 1024,
        diskCacheEnabled: Bool = true,
        diskCacheSizeLimit: Int64 = 100 * 1024 * 1024,
        diskCacheAgeLimit: TimeInterval = 7 * 24 * 60 * 60
    ) {
        self.memoryCountLimit = memoryCountLimit
        self.memoryCostLimit = memoryCostLimit
        self.diskCacheEnabled = diskCacheEnabled
        self.diskCacheSizeLimit = diskCacheSizeLimit
        self.diskCacheAgeLimit = diskCacheAgeLimit
    }

    public static let `default` = ImageCacheConfiguration()

    /// Configuration with disk cache disabled (memory only)
    public static let memoryOnly = ImageCacheConfiguration(
        diskCacheEnabled: false
    )

    /// Configuration for testing with small limits
    public static let testing = ImageCacheConfiguration(
        memoryCountLimit: 10,
        memoryCostLimit: 1 * 1024 * 1024,
        diskCacheEnabled: true,
        diskCacheSizeLimit: 1 * 1024 * 1024,
        diskCacheAgeLimit: 60
    )
}
