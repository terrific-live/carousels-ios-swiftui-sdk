//
//  AnalyticsServiceImpl+Carousel.swift
//  TerrificCarouselSDK
//

import Foundation

// MARK: - Carousel Events
extension AnalyticsServiceImpl {

    func trackCarouselLoaded(
        carouselId: String,
        assets: [TimelineAssetDTO],
        externalUserId: String?
    ) async throws {
        let sessionId = carouselId

        let auxData = CarouselLoadedAuxData(
            assetIds: assets.map { $0.id },
            assetTimestamps: assets.map { $0.timestampMilliseconds },
            externalUserId: externalUserId,
            userAgent: configuration.userAgent,
            parentUrl: "",
            position: nil,
            totalAssets: assets.count
        )

        let body = AnalyticsEventRequestBody(
            name: .timelineCarouselLoaded,
            userId: configuration.userId,
            sessionId: sessionId,
            auxData: auxData
        )

        let request = AnalyticsEventAPIRequest(
            storeId: configuration.storeId,
            requestBody: body
        )

        let _ = try await client.send(request)
    }

    func trackCarouselViewed(
        carouselId: String,
        assets: [TimelineAssetDTO],
        externalUserId: String?
    ) async throws {
        let sessionId = carouselId

        let auxData = CarouselViewedAuxData(
            assetIds: assets.map { $0.id },
            assetTimestamps: assets.map { $0.timestampMilliseconds },
            externalUserId: externalUserId,
            userAgent: configuration.userAgent,
            parentUrl: "",
            position: nil,
            totalAssets: assets.count
        )

        let body = AnalyticsEventRequestBody(
            name: .timelineCarouselViewed,
            userId: configuration.userId,
            sessionId: sessionId,
            auxData: auxData
        )

        let request = AnalyticsEventAPIRequest(
            storeId: configuration.storeId,
            requestBody: body
        )

        let _ = try await client.send(request)
    }

    func trackCarouselClicked(
        carouselId: String,
        clickedAsset: TimelineAssetDTO,
        allAssets: [TimelineAssetDTO],
        position: Int,
        externalUserId: String?
    ) async throws {
        let sessionId = sessionId(carouselId: carouselId, assetId: clickedAsset.id)

        let auxData = CarouselClickedAuxData(
            assetId: clickedAsset.id,
            assetIds: allAssets.map { $0.id },
            assetTimestamps: allAssets.map { $0.timestampMilliseconds },
            brandName: clickedAsset.brandName,
            campaignName: clickedAsset.campaignName,
            customProducts: [],
            externalUserId: externalUserId,
            parentUrl: "",
            position: position,
            totalAssets: allAssets.count
        )

        let body = AnalyticsEventRequestBody(
            name: .timelineCarouselClicked,
            userId: configuration.userId,
            sessionId: sessionId,
            auxData: auxData
        )

        let request = AnalyticsEventAPIRequest(
            storeId: configuration.storeId,
            requestBody: body
        )

        let _ = try await client.send(request)
    }
}
