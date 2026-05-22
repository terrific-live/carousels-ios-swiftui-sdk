//
//  TimelineFeedServiceTests.swift
//  TerrificCarouselSDKTests
//

import XCTest
import HTTPClient
@testable import TerrificCarouselSDK

final class TimelineFeedServiceTests: XCTestCase {

    // MARK: - Properties
    private var sut: TimelineFeedService!
    private var mockTransport: MockNetworkTransport!
    private var client: Client!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockTransport = MockNetworkTransport()
        client = Client(
            base: "https://api.test.com",
            version: nil,
            transport: mockTransport
        )

        let config = APIConfiguration(
            storeId: "test-store",
            carouselId: "test-carousel",
            shopPageUrl: "https://shop.example.com"
        )

        sut = TimelineFeedService(
            client: client,
            configuration: config,
            terrificUserId: "user-123"
        )
    }

    override func tearDown() {
        sut = nil
        client = nil
        mockTransport = nil
        super.tearDown()
    }

    // MARK: - Request Construction Tests

    func testFetchAssets_constructsCorrectPath() async throws {
        // Given
        let response = TimelineResponseDTO(assets: [], carouselConfig: nil, anchor: nil)
        mockTransport.stubSuccess(response)

        // When
        _ = try await sut.fetchAssets(
            for: "test-carousel",
            page: 1,
            itemsPerPage: 10,
            offset: 0,
            anchor: nil,
            startAssetId: nil
        )

        // Then
        let request = mockTransport.lastRequest
        XCTAssertNotNil(request)
        XCTAssertTrue(request?.url?.path.contains("/api/v1/stores/test-store/carousel/test-carousel") ?? false)
    }

    func testFetchAssets_includesQueryParameters() async throws {
        // Given
        let response = TimelineResponseDTO(assets: [], carouselConfig: nil, anchor: nil)
        mockTransport.stubSuccess(response)

        // When
        _ = try await sut.fetchAssets(
            for: "test-carousel",
            page: 1,
            itemsPerPage: 10,
            offset: 0,
            anchor: nil,
            startAssetId: nil
        )

        // Then
        let request = mockTransport.lastRequest
        let urlString = request?.url?.absoluteString ?? ""

        XCTAssertTrue(urlString.contains("number-of-items=10"))
        XCTAssertTrue(urlString.contains("terrificUserId=user-123"))
    }

    func testFetchAssets_includesOffsetWhenGreaterThanZero() async throws {
        // Given
        let response = TimelineResponseDTO(assets: [], carouselConfig: nil, anchor: nil)
        mockTransport.stubSuccess(response)

        // When - page 2 with offset 5
        _ = try await sut.fetchAssets(
            for: "test-carousel",
            page: 2,
            itemsPerPage: 10,
            offset: 5,
            anchor: nil,
            startAssetId: nil
        )

        // Then - offset should be 5 + (2-1)*10 = 15
        let urlString = mockTransport.lastRequest?.url?.absoluteString ?? ""
        XCTAssertTrue(urlString.contains("offset=15"))
    }

    func testFetchAssets_omitsOffsetWhenZero() async throws {
        // Given
        let response = TimelineResponseDTO(assets: [], carouselConfig: nil, anchor: nil)
        mockTransport.stubSuccess(response)

        // When - page 1, offset 0
        _ = try await sut.fetchAssets(
            for: "test-carousel",
            page: 1,
            itemsPerPage: 10,
            offset: 0,
            anchor: nil,
            startAssetId: nil
        )

        // Then - offset should not be in URL (it's 0)
        let urlString = mockTransport.lastRequest?.url?.absoluteString ?? ""
        XCTAssertFalse(urlString.contains("offset="))
    }

    // MARK: - Response Handling Tests

    func testFetchAssets_returnsAssets() async throws {
        // Given
        let assets = [TimelineAssetDTO.sample(id: "1"), TimelineAssetDTO.sample(id: "2")]
        let response = TimelineResponseDTO(assets: assets, carouselConfig: nil, anchor: nil)
        mockTransport.stubSuccess(response)

        // When
        let result = try await sut.fetchAssets(
            for: "test-carousel",
            page: 1,
            itemsPerPage: 10,
            offset: 0,
            anchor: nil,
            startAssetId: nil
        )

        // Then
        XCTAssertEqual(result.assets.count, 2)
        XCTAssertEqual(result.assets[0].id, "1")
        XCTAssertEqual(result.assets[1].id, "2")
    }

    func testFetchAssets_returnsCarouselConfig() async throws {
        // Given
        let config = CarouselConfigDTO(
            timestampFormat: "{DD}/{MM}",
            showName: true,
            carouselAutoPlay: true,
            carouselAutoPlayInterval: 5.0,
            name: "Test Carousel",
            showTimestamps: true,
            mapBrandNameToProductName: false,
            swipeUpText: nil
        )
        let response = TimelineResponseDTO(assets: [], carouselConfig: config, anchor: nil)
        mockTransport.stubSuccess(response)

        // When
        let result = try await sut.fetchAssets(
            for: "test-carousel",
            page: 1,
            itemsPerPage: 10,
            offset: 0,
            anchor: nil,
            startAssetId: nil
        )

        // Then
        XCTAssertEqual(result.carouselConfig?.name, "Test Carousel")
        XCTAssertEqual(result.carouselConfig?.carouselAutoPlay, true)
    }

    func testFetchAssets_returnsAnchor() async throws {
        // Given
        let response = TimelineResponseDTO(assets: [], carouselConfig: nil, anchor: "next-page-anchor")
        mockTransport.stubSuccess(response)

        // When
        let result = try await sut.fetchAssets(
            for: "test-carousel",
            page: 1,
            itemsPerPage: 10,
            offset: 0,
            anchor: nil,
            startAssetId: nil
        )

        // Then
        XCTAssertEqual(result.anchor, "next-page-anchor")
    }

    func testFetchAssets_returnsEmptyArrayWhenNilResponse() async throws {
        // Given - transport returns nil data
        mockTransport.stubbedData = nil
        mockTransport.stubbedResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        // When
        let result = try await sut.fetchAssets(
            for: "test-carousel",
            page: 1,
            itemsPerPage: 10,
            offset: 0,
            anchor: nil,
            startAssetId: nil
        )

        // Then
        XCTAssertTrue(result.assets.isEmpty)
    }

    // MARK: - Error Handling Tests

    func testFetchAssets_throwsOnNetworkError() async {
        // Given
        let networkError = NSError(domain: "Network", code: -1009, userInfo: [NSLocalizedDescriptionKey: "No connection"])
        mockTransport.stubError(networkError)

        // When/Then
        do {
            _ = try await sut.fetchAssets(
                for: "test-carousel",
                page: 1,
                itemsPerPage: 10,
                offset: 0,
                anchor: nil,
                startAssetId: nil
            )
            XCTFail("Expected error to be thrown")
        } catch {
            // Expected
            XCTAssertNotNil(error)
        }
    }
}
