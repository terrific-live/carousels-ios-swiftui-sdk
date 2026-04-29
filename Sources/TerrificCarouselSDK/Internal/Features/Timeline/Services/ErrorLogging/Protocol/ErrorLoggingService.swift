//
//  ErrorLoggingService.swift
//  TerrificCarouselSDK
//

import Foundation

// MARK: - ErrorSeverity
enum ErrorSeverity: String, Encodable {
    case error = "ERROR"
    case warning = "WARNING"
    case info = "INFO"
}

// MARK: - ErrorRoute
enum ErrorRoute: String {
    case horizontalCarousel = "HorizontalCarousel"
    case verticalCarousel = "VerticalCarousel"
}

// MARK: - ErrorLoggingService
/// Protocol for logging errors to the backend
protocol ErrorLoggingService {
    /// Log an error that occurred during carousel operation
    /// - Parameters:
    ///   - message: Error message to log
    ///   - severity: Error severity level
    ///   - route: Where the error occurred (HorizontalCarousel or VerticalCarousel)
    ///   - metadata: Additional context information
    func logError(
        message: String,
        severity: ErrorSeverity,
        route: ErrorRoute,
        metadata: [String: String]?
    )
}
