//
//  LogMediaPlayback.swift
//  MediaPlayback
//

import Foundation

/// Configuration for MediaPlayback logging
public enum MediaPlaybackLogger {
    /// Set to `true` to enable debug logging for MediaPlayback
    public static var isEnabled: Bool = false
}

/// Logs a message for MediaPlayback if logging is enabled
/// - Parameter message: The message to log
public func logMediaPlayback(_ message: String) {
    #if DEBUG
    guard MediaPlaybackLogger.isEnabled else { return }
    debugPrint("🎬 " + message)
    #endif
}
