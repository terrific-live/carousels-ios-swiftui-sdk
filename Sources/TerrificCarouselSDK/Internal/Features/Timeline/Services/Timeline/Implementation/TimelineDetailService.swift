//
//  TimelineDetailService.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 25.02.2026.
//

import Foundation
import HTTPClient

// MARK: - TimelineDetailService
/// Real implementation of TimelineService for Detail (vertical display)
/// Uses Client with interceptor pipeline
struct TimelineDetailService: TimelineService {

    // MARK: - Dependencies
    private let client: Client
    private let configuration: APIConfiguration
    private let terrificUserId: String

    // MARK: - Init
    init(
        client: Client,
        configuration: APIConfiguration,
        terrificUserId: String
    ) {
        self.client = client
        self.configuration = configuration
        self.terrificUserId = terrificUserId
    }

    // MARK: - TimelineService
    func fetchAssets(
        for carouselId: String,
        page: Int,
        itemsPerPage: Int,
        offset: Int,
        anchor: String?,
        startAssetId: String?
    ) async throws -> TimelineServiceResult {
        let request = TimelineDetailAPIRequest(
            storeId: configuration.storeId,
            carouselId: configuration.carouselId,
            numberOfItems: itemsPerPage,
            offset: offset + (page - 1) * itemsPerPage,
            shopPageUrl: configuration.shopPageUrl,
            terrificUserId: terrificUserId,
            anchor: anchor,
            startAssetId: startAssetId
        )

        let response = try await client.send(request)
        return TimelineServiceResult(
            assets: response?.assets ?? [],
            carouselConfig: response?.carouselConfig,
            anchor: response?.anchor
        )
    }
}
