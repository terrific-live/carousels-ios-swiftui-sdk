//
//  APIConfigurationTests.swift
//  TerrificCarouselSDKTests
//

import XCTest
@testable import TerrificCarouselSDK

final class APIConfigurationTests: XCTestCase {

    // MARK: - Default URLs

    func test_init_defaultBaseURL_isProduction() {
        let sut = APIConfiguration(storeId: "store", carouselId: "carousel")

        XCTAssertEqual(sut.baseURL?.absoluteString, "https://terrific-live-polls.web.app")
    }

    func test_init_defaultAnalyticsBaseURL_isProduction() {
        let sut = APIConfiguration(storeId: "store", carouselId: "carousel")

        XCTAssertEqual(sut.analyticsBaseURL.absoluteString, "https://us-central1-terrific-live.cloudfunctions.net")
    }

    // MARK: - Custom URLs

    func test_init_customBaseURL_overridesDefault() {
        let sut = APIConfiguration(
            storeId: "store",
            carouselId: "carousel",
            baseURL: "https://terrific-staging-polls.web.app"
        )

        XCTAssertEqual(sut.baseURL?.absoluteString, "https://terrific-staging-polls.web.app")
    }

    func test_init_customAnalyticsBaseURL_overridesDefault() {
        let sut = APIConfiguration(
            storeId: "store",
            carouselId: "carousel",
            analyticsBaseURL: "https://us-central1-terrific-deploy.cloudfunctions.net"
        )

        XCTAssertEqual(sut.analyticsBaseURL.absoluteString, "https://us-central1-terrific-deploy.cloudfunctions.net")
    }

    func test_init_customBaseURL_doesNotAffectAnalyticsBaseURL() {
        let sut = APIConfiguration(
            storeId: "store",
            carouselId: "carousel",
            baseURL: "https://terrific-staging-polls.web.app"
        )

        XCTAssertEqual(sut.analyticsBaseURL.absoluteString, "https://us-central1-terrific-live.cloudfunctions.net")
    }

    func test_init_customAnalyticsBaseURL_doesNotAffectBaseURL() {
        let sut = APIConfiguration(
            storeId: "store",
            carouselId: "carousel",
            analyticsBaseURL: "https://us-central1-terrific-deploy.cloudfunctions.net"
        )

        XCTAssertEqual(sut.baseURL?.absoluteString, "https://terrific-live-polls.web.app")
    }

    // MARK: - Properties

    func test_init_storesStoreId() {
        let sut = APIConfiguration(storeId: "my-store", carouselId: "carousel")

        XCTAssertEqual(sut.storeId, "my-store")
    }

    func test_init_storesCarouselId() {
        let sut = APIConfiguration(storeId: "store", carouselId: "my-carousel")

        XCTAssertEqual(sut.carouselId, "my-carousel")
    }

    func test_init_shopPageUrl_defaultsToNil() {
        let sut = APIConfiguration(storeId: "store", carouselId: "carousel")

        XCTAssertNil(sut.shopPageUrl)
    }

    func test_init_shopPageUrl_storesValue() {
        let sut = APIConfiguration(
            storeId: "store",
            carouselId: "carousel",
            shopPageUrl: "https://shop.example.com"
        )

        XCTAssertEqual(sut.shopPageUrl, "https://shop.example.com")
    }

    // MARK: - Invalid URL Fallback

    func test_init_invalidBaseURL_fallsBackToDefault() {
        let sut = APIConfiguration(
            storeId: "store",
            carouselId: "carousel",
            baseURL: ""
        )

        XCTAssertEqual(sut.baseURL?.absoluteString, "https://terrific-live-polls.web.app")
    }

    func test_init_invalidAnalyticsBaseURL_fallsBackToDefault() {
        let sut = APIConfiguration(
            storeId: "store",
            carouselId: "carousel",
            analyticsBaseURL: ""
        )

        XCTAssertEqual(sut.analyticsBaseURL.absoluteString, "https://us-central1-terrific-live.cloudfunctions.net")
    }

    // MARK: - Nil URL Parameters

    func test_init_nilBaseURL_usesDefault() {
        let sut = APIConfiguration(
            storeId: "store",
            carouselId: "carousel",
            baseURL: nil
        )

        XCTAssertEqual(sut.baseURL?.absoluteString, "https://terrific-live-polls.web.app")
    }

    func test_init_nilAnalyticsBaseURL_usesDefault() {
        let sut = APIConfiguration(
            storeId: "store",
            carouselId: "carousel",
            analyticsBaseURL: nil
        )

        XCTAssertEqual(sut.analyticsBaseURL.absoluteString, "https://us-central1-terrific-live.cloudfunctions.net")
    }
}
