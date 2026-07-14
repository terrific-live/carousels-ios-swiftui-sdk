//
//  AnalyticsServiceImpl+Asset.swift
//  TerrificCarouselSDK
//

import Foundation

// MARK: - Asset Events
extension AnalyticsServiceImpl {

    func trackAssetViewStarted(
        carouselId: String,
        asset: TimelineAssetDTO,
        position: Int,
        externalUserId: String?
    ) async throws {
        let sessionId = sessionId(carouselId: carouselId, assetId: asset.id)

        let assetType = assetTypeString(from: asset.type)
        let customProducts = mapCustomProducts(from: asset.products)
        let products = mapAnalyticProducts(from: asset.products)

        let auxData = AssetViewStartedAuxData(
            assetType: assetType,
            brandName: asset.brandName,
            campaignName: asset.campaignName,
            customProducts: customProducts,
            externalUserId: externalUserId,
            fixedPosition: position,
            parentUrl: "",
            position: position,
            products: products
        )

        let body = AnalyticsEventRequestBody(
            name: .timelineAssetViewStarted,
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

    func trackAssetViewEnded(
        carouselId: String,
        asset: TimelineAssetDTO,
        position: Int,
        viewDurationMs: Int,
        netoWatchTimeMs: Int,
        externalUserId: String?
    ) async throws {
        let sessionId = sessionId(carouselId: carouselId, assetId: asset.id)

        let assetType = assetTypeString(from: asset.type)
        let customProducts = mapCustomProducts(from: asset.products)
        let products = mapAnalyticProducts(from: asset.products)

        let auxData = AssetViewEndedAuxData(
            assetType: assetType,
            brandName: asset.brandName,
            campaignName: asset.campaignName,
            customProducts: customProducts,
            drawerOpenDurationMs: 0,
            externalUserId: externalUserId,
            netoAssetWatchTimeMs: netoWatchTimeMs,
            parentUrl: "",
            position: position,
            products: products,
            viewDurationMs: viewDurationMs
        )

        let body = AnalyticsEventRequestBody(
            name: .timelineAssetViewEnded,
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

    func trackAssetViewed(
        carouselId: String,
        asset: TimelineAssetDTO,
        position: Int,
        isInitialView: Bool,
        externalUserId: String?
    ) async throws {
        let sessionId = sessionId(carouselId: carouselId, assetId: asset.id)

        let customProducts = mapCustomProducts(from: asset.products)

        let auxData = AssetViewedAuxData(
            assetTimestamp: asset.timestampMilliseconds,
            brandName: asset.brandName,
            campaignName: asset.campaignName,
            externalUserId: externalUserId,
            userAgent: configuration.userAgent,
            parentUrl: "",
            isInitialView: isInitialView,
            position: position,
            fixedPosition: position,
            customProducts: customProducts
        )

        let body = AnalyticsEventRequestBody(
            name: .timelineCarouselAssetViewed,
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

    func trackAssetLiked(
        carouselId: String,
        asset: TimelineAssetDTO,
        externalUserId: String?
    ) async throws {
        let sessionId = sessionId(carouselId: carouselId, assetId: asset.id)

        let auxData = AssetLikedAuxData(
            brandName: asset.brandName,
            campaignName: asset.campaignName,
            externalUserId: externalUserId,
            userAgent: configuration.userAgent,
            parentUrl: "",
            position: asset.position
        )

        let body = AnalyticsEventRequestBody(
            name: .timelineAssetLiked,
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

    func trackAssetShared(
        carouselId: String,
        asset: TimelineAssetDTO,
        position: Int,
        externalUserId: String?
    ) async throws {
        let sessionId = sessionId(carouselId: carouselId, assetId: asset.id)

        let customProducts = mapCustomProducts(from: asset.products)

        let auxData = AssetSharedAuxData(
            brandName: asset.brandName,
            campaignName: asset.campaignName,
            customProducts: customProducts,
            externalUserId: externalUserId,
            parentUrl: "",
            position: position,
            userAgent: configuration.userAgent
        )

        let body = AnalyticsEventRequestBody(
            name: .timelineAssetShared,
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
