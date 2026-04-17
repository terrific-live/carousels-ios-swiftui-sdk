//
//  AnalyticsLogger.swift
//  CarouselDemo
//

import Foundation
import OSLog

/// Configuration for Analytics logging
public enum AnalyticsLogger {
    /// Set to `true` to enable error logging for Analytics
    nonisolated(unsafe) public static var isEnabled: Bool = false

    // MARK: - Logger
    static let logger = Logger(subsystem: "CarouselDemo", category: "Analytics")

    // MARK: - Logging Methods
    static func success(_ eventName: String) {
        guard isEnabled else { return }
        logger.log("✅ Analytic event \(eventName, privacy: .public) (Success)")
    }

    static func error(_ eventName: String, errorMessage: String?) {
        guard isEnabled else { return }
        logger.error("❌ Analytic event \(eventName, privacy: .public), \(errorMessage ?? "", privacy: .public) (Failed)")
    }

    static func info(_ message: String) {
        guard isEnabled else { return }
        logger.info("ℹ️ \(message, privacy: .public)")
    }
}
