//
//  LogImageLoader.swift
//  ImageLoader
//

import Foundation

/// Configuration for ImageLoader logging
public enum ImageLoaderLogger {
    /// Set to `true` to enable debug logging for ImageLoader
    public static var isEnabled: Bool = false
}

/// Logs a message for ImageLoader if logging is enabled
/// - Parameter message: The message to log
func logImageLoader(_ message: String) {
    #if DEBUG
    guard ImageLoaderLogger.isEnabled else { return }
    debugPrint("📥 [ImageLoader] " + message)
    #endif
}

/// Logs a disk cache message for ImageLoader if logging is enabled
/// - Parameter message: The message to log
func logImageDiskCache(_ message: String) {
    #if DEBUG
    guard ImageLoaderLogger.isEnabled else { return }
    debugPrint("💾 [ImageDiskCache] " + message)
    #endif
}
