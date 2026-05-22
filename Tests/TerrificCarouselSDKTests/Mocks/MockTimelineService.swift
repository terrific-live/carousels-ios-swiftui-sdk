//
//  MockTimelineService.swift
//  TerrificCarouselSDKTests
//

import Foundation
@testable import TerrificCarouselSDK

@MainActor
final class MockTimelineService: TimelineService {

    // MARK: - Stubbed Responses
    var stubbedResult: TimelineServiceResult?
    var stubbedError: Error?

    // MARK: - Call Tracking
    private(set) var fetchAssetsCallCount = 0
    private(set) var lastFetchCarouselId: String?
    private(set) var lastFetchPage: Int?
    private(set) var lastFetchItemsPerPage: Int?
    private(set) var lastFetchOffset: Int?
    private(set) var lastFetchAnchor: String?
    private(set) var lastFetchStartAssetId: String?

    // MARK: - TimelineService
    func fetchAssets(
        for carouselId: String,
        page: Int,
        itemsPerPage: Int,
        offset: Int,
        anchor: String?,
        startAssetId: String?
    ) async throws -> TimelineServiceResult {
        fetchAssetsCallCount += 1
        lastFetchCarouselId = carouselId
        lastFetchPage = page
        lastFetchItemsPerPage = itemsPerPage
        lastFetchOffset = offset
        lastFetchAnchor = anchor
        lastFetchStartAssetId = startAssetId

        if let error = stubbedError {
            throw error
        }

        return stubbedResult ?? TimelineServiceResult(
            assets: [],
            carouselConfig: nil,
            anchor: nil
        )
    }

    // MARK: - Reset
    func reset() {
        stubbedResult = nil
        stubbedError = nil
        fetchAssetsCallCount = 0
        lastFetchCarouselId = nil
        lastFetchPage = nil
        lastFetchItemsPerPage = nil
        lastFetchOffset = nil
        lastFetchAnchor = nil
        lastFetchStartAssetId = nil
    }
}
