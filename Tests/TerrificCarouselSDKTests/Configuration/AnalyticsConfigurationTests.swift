//
//  AnalyticsConfigurationTests.swift
//  TerrificCarouselSDKTests
//

import XCTest
@testable import TerrificCarouselSDK

final class AnalyticsConfigurationTests: XCTestCase {

    // MARK: - Init

    func test_init_storesBaseURL() {
        let url = URL(string: "https://analytics.example.com")!
        let sut = AnalyticsConfiguration(baseURL: url, storeId: "store", userId: "user")

        XCTAssertEqual(sut.baseURL, url)
    }

    func test_init_storesStoreId() {
        let sut = AnalyticsConfiguration(
            baseURL: URL(string: "https://analytics.example.com")!,
            storeId: "my-store",
            userId: "user"
        )

        XCTAssertEqual(sut.storeId, "my-store")
    }

    func test_init_storesUserId() {
        let sut = AnalyticsConfiguration(
            baseURL: URL(string: "https://analytics.example.com")!,
            storeId: "store",
            userId: "my-user"
        )

        XCTAssertEqual(sut.userId, "my-user")
    }

    // MARK: - Factory: make

    func test_make_usesAnalyticsBaseURL_notContentBaseURL() {
        let apiConfig = APIConfiguration(
            storeId: "store",
            carouselId: "carousel",
            baseURL: "https://terrific-live-polls.web.app",
            analyticsBaseURL: "https://us-central1-terrific-live.cloudfunctions.net"
        )

        let sut = AnalyticsConfiguration.make(apiConfig: apiConfig, terrificUserId: "user-1")

        XCTAssertEqual(sut.baseURL?.absoluteString, "https://us-central1-terrific-live.cloudfunctions.net")
    }

    func test_make_stagingConfig_usesStagingAnalyticsURL() {
        let apiConfig = APIConfiguration(
            storeId: "store",
            carouselId: "carousel",
            baseURL: "https://terrific-staging-polls.web.app",
            analyticsBaseURL: "https://us-central1-terrific-deploy.cloudfunctions.net"
        )

        let sut = AnalyticsConfiguration.make(apiConfig: apiConfig, terrificUserId: "user-1")

        XCTAssertEqual(sut.baseURL?.absoluteString, "https://us-central1-terrific-deploy.cloudfunctions.net")
    }

    func test_make_passesStoreId() {
        let apiConfig = APIConfiguration(
            storeId: "test-store-id",
            carouselId: "carousel"
        )

        let sut = AnalyticsConfiguration.make(apiConfig: apiConfig, terrificUserId: "user-1")

        XCTAssertEqual(sut.storeId, "test-store-id")
    }

    func test_make_passesTerrificUserId() {
        let apiConfig = APIConfiguration(
            storeId: "store",
            carouselId: "carousel"
        )

        let sut = AnalyticsConfiguration.make(apiConfig: apiConfig, terrificUserId: "terrific-user-42")

        XCTAssertEqual(sut.userId, "terrific-user-42")
    }

    func test_make_defaultAnalyticsURL_isProduction() {
        let apiConfig = APIConfiguration(
            storeId: "store",
            carouselId: "carousel"
        )

        let sut = AnalyticsConfiguration.make(apiConfig: apiConfig, terrificUserId: "user-1")

        XCTAssertEqual(sut.baseURL?.absoluteString, "https://us-central1-terrific-live.cloudfunctions.net")
    }

    // MARK: - isAnalyticsEnabled

    func test_isAnalyticsEnabled_inDebug_isFalse() {
        // Tests run in DEBUG configuration
        XCTAssertFalse(AnalyticsConfiguration.isAnalyticsEnabled)
    }

    // MARK: - User Agent

    func test_userAgent_containsExpectedComponents() {
        let sut = AnalyticsConfiguration(
            baseURL: URL(string: "https://analytics.example.com")!,
            storeId: "store",
            userId: "user"
        )

        let userAgent = sut.userAgent
        XCTAssertTrue(userAgent.contains("iOS"))
        XCTAssertTrue(userAgent.contains("AppVersion/"))
        XCTAssertTrue(userAgent.contains("Build/"))
    }
}
