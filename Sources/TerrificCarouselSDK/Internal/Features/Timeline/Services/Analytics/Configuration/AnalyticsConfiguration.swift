//
//  AnalyticsConfiguration.swift
//  CarouselDemo
//

import Foundation

// MARK: - AnalyticsConfiguration
struct AnalyticsConfiguration {
    let baseURL: URL
    let storeId: String
    let userId: String

    // MARK: - Init
    init(
        baseURL: String,
        storeId: String,
        userId: String
    ) {
        self.baseURL = URL(string: baseURL)!
        self.storeId = storeId
        self.userId = userId
    }

    // MARK: - Computed
    var userAgent: String {
        // Format: AppName/Version (Platform; OS Version)
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        let osVersion = ProcessInfo.processInfo.operatingSystemVersionString
        return "Carousel/\(appVersion).\(buildNumber) (iOS; \(osVersion))"
    }
}

// MARK: - Predefined Configurations
extension AnalyticsConfiguration {
    /// Staging analytics endpoint
    static func staging(
        apiConfig: APIConfiguration,
        terrificUserId: String
    ) -> AnalyticsConfiguration {
        AnalyticsConfiguration(
            baseURL: "https://us-central1-terrific-deploy.cloudfunctions.net",
            storeId: apiConfig.storeId,
            userId: terrificUserId
        )
    }

    /// Production analytics endpoint
    static func production(
        apiConfig: APIConfiguration,
        terrificUserId: String
    ) -> AnalyticsConfiguration {
        AnalyticsConfiguration(
            baseURL: "https://us-central1-terrific-live.cloudfunctions.net",
            storeId: apiConfig.storeId,
            userId: terrificUserId
        )
    }
}
