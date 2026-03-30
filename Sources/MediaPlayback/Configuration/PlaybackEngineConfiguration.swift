//
//  PlaybackEngineConfiguration.swift
//  MediaPlayback
//

import Foundation

// MARK: - PlaybackEngineConfiguration
/// Configuration for playback engine timeouts and retry behavior
public struct PlaybackEngineConfiguration: Sendable {
    /// Timeout for initial video loading (seconds)
    public let loadingTimeout: TimeInterval

    /// Number of retry attempts on failure
    public let maxRetryAttempts: Int

    /// Delay between retry attempts (seconds)
    public let retryDelay: TimeInterval

    public init(
        loadingTimeout: TimeInterval = 30.0,
        maxRetryAttempts: Int = 2,
        retryDelay: TimeInterval = 1.0
    ) {
        self.loadingTimeout = loadingTimeout
        self.maxRetryAttempts = maxRetryAttempts
        self.retryDelay = retryDelay
    }

    public static let `default` = PlaybackEngineConfiguration(
        loadingTimeout: 30.0,
        maxRetryAttempts: 2,
        retryDelay: 1.0
    )

    public static let aggressive = PlaybackEngineConfiguration(
        loadingTimeout: 15.0,
        maxRetryAttempts: 3,
        retryDelay: 0.5
    )
}
