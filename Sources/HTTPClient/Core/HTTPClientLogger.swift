//
//  HTTPClientLogger.swift
//  HTTPClient
//

import Foundation

/// Configuration for HTTPClient logging
public enum HTTPClientLogger {
    /// Set to `true` to enable debug logging for HTTPClient (CURL and response logging)
    nonisolated(unsafe) public static var isEnabled: Bool = false
}
