//
//  MockErrorLoggingService.swift
//  TerrificCarouselSDKTests
//

import Foundation
@testable import TerrificCarouselSDK

final class MockErrorLoggingService: ErrorLoggingService {

    // MARK: - Call Tracking
    struct LoggedError {
        let message: String
        let severity: ErrorSeverity
        let route: ErrorRoute
        let metadata: [String: String]?
    }

    private(set) var loggedErrors: [LoggedError] = []

    // MARK: - ErrorLoggingService
    func logError(
        message: String,
        severity: ErrorSeverity,
        route: ErrorRoute,
        metadata: [String: String]?
    ) {
        loggedErrors.append(LoggedError(
            message: message,
            severity: severity,
            route: route,
            metadata: metadata
        ))
    }

    // MARK: - Reset
    func reset() {
        loggedErrors.removeAll()
    }
}
