//
//  ErrorLoggingConfiguration.swift
//  TerrificCarouselSDK
//

import Foundation

// MARK: - ErrorLoggingConfiguration
struct ErrorLoggingConfiguration {
    let baseURL: URL?
    let project: String

    // MARK: - Init
    init(baseURL: String, project: String = "terrific-carousel-ios-sdk") {
        self.baseURL = URL(string: baseURL)
        self.project = project
    }

    /// Returns staging in DEBUG builds, production in Release builds
    static var current: ErrorLoggingConfiguration {
        #if DEBUG
        return .staging
        #else
        return .production
        #endif
    }
}

// MARK: - Predefined Configurations
extension ErrorLoggingConfiguration {
    /// Staging error logging endpoint
    static var staging: ErrorLoggingConfiguration {
        ErrorLoggingConfiguration(
            baseURL: "https://app-terrific-deploy-stage.terrific.live"
        )
    }

    /// Production error logging endpoint
    static var production: ErrorLoggingConfiguration {
        ErrorLoggingConfiguration(
            baseURL: "https://app-terrific-live-prod.terrific.live"
        )
    }
}
