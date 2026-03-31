//
//  LogPagination.swift
//  Pagination
//

import Foundation

/// Configuration for Pagination logging
public enum PaginationLogger {
    /// Set to `true` to enable debug logging for Pagination
    public static var isEnabled: Bool = false
}

/// Logs a message for Pagination if logging is enabled
/// - Parameter message: The message to log
func logPagination(_ message: String) {
    #if DEBUG
    guard PaginationLogger.isEnabled else { return }
    debugPrint("📖 [Paginator] " + message)
    #endif
}
