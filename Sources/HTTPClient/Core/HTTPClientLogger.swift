//
//  HTTPClientLogger.swift
//  HTTPClient
//

import Foundation

/// Configuration for HTTPClient logging
public enum HTTPClientLogger {
    /// Set to `true` to enable debug logging for HTTPClient (CURL and response logging)
    nonisolated(unsafe) public static var isEnabled: Bool = false

    /// Logs adapter chain events when enabled (DEBUG builds only)
    static func logAdapterFallback(
        adapter: String,
        responseType: String,
        error: Error?,
        dataPreview: String? = nil
    ) {
        #if DEBUG
        guard isEnabled else { return }

        if let error {
            print("🔄 [\(adapter)] Failed to decode \(responseType): \(error.localizedDescription)")
        } else {
            print("🔄 [\(adapter)] Skipping - not handling \(responseType)")
        }
        if let dataPreview {
            print("   Data preview: \(dataPreview)")
        }
        #endif
    }
}
