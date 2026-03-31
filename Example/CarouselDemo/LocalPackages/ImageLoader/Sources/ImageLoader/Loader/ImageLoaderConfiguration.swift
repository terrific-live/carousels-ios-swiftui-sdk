//
//  ImageLoaderConfiguration.swift
//  ImageLoader
//

import Foundation

// MARK: - ImageLoaderConfiguration
public struct ImageLoaderConfiguration: Sendable {
    /// Timeout for image downloads in seconds
    public let downloadTimeout: TimeInterval

    /// Number of retry attempts on timeout
    public let maxRetryAttempts: Int

    public init(
        downloadTimeout: TimeInterval = 15.0,
        maxRetryAttempts: Int = 1
    ) {
        self.downloadTimeout = downloadTimeout
        self.maxRetryAttempts = maxRetryAttempts
    }

    public nonisolated static let `default` = ImageLoaderConfiguration(
        downloadTimeout: 15.0,
        maxRetryAttempts: 1
    )

    public nonisolated static let aggressive = ImageLoaderConfiguration(
        downloadTimeout: 10.0,
        maxRetryAttempts: 2
    )

    /// Configuration for testing with short timeouts
    public nonisolated static let testing = ImageLoaderConfiguration(
        downloadTimeout: 5.0,
        maxRetryAttempts: 0
    )
}
