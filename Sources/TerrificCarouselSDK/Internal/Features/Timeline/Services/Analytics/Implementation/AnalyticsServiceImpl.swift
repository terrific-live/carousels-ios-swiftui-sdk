//
//  AnalyticsServiceImpl.swift
//  CarouselDemo
//

import Foundation
import HTTPClient

// MARK: - AnalyticsServiceImpl
/// Real implementation of AnalyticsService
struct AnalyticsServiceImpl: AnalyticsService {

    // MARK: - Dependencies
    private let client: Client
    private let configuration: AnalyticsConfiguration

    // MARK: - Init
    init(client: Client, configuration: AnalyticsConfiguration) {
        self.client = client
        self.configuration = configuration
    }

    // MARK: - AnalyticsService

    func trackTimelineOpened(
        carouselId: String,
        parentUrl: String,
        externalUserId: String?
    ) async throws {
        // sessionId is carouselId only (not related to specific asset)
        let sessionId = carouselId

        let auxData = TimelineOpenedAuxData(
            externalUserId: externalUserId,
            userAgent: configuration.userAgent,
            parentUrl: ""
        )

        let body = AnalyticsEventRequestBody(
            name: .timelineOpened,
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

    func trackTimelineClosed(
        carouselId: String,
        parentUrl: String,
        totalOpenDurationMs: Int,
        activeViewDurationMs: Int,
        externalUserId: String?
    ) async throws {
        // sessionId is carouselId only (not related to specific asset)
        let sessionId = carouselId

        let auxData = TimelineClosedAuxData(
            activeViewDurationMs: activeViewDurationMs,
            externalUserId: externalUserId,
            parentUrl: "",
            totalOpenDurationMs: totalOpenDurationMs
        )

        let body = AnalyticsEventRequestBody(
            name: .timelineClosed,
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

    func trackAssetViewStarted(
        carouselId: String,
        asset: TimelineAssetDTO,
        position: Int,
        externalUserId: String?
    ) async throws {
        // Build sessionId: carouselId~assetId
        let sessionId = "\(carouselId)~\(asset.id)"

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
        // Build sessionId: carouselId~assetId
        let sessionId = "\(carouselId)~\(asset.id)"

        let assetType = assetTypeString(from: asset.type)
        let customProducts = mapCustomProducts(from: asset.products)
        let products = mapAnalyticProducts(from: asset.products)

        let auxData = AssetViewEndedAuxData(
            assetType: assetType,
            brandName: asset.brandName,
            campaignName: asset.campaignName,
            customProducts: customProducts,
            drawerOpenDurationMs: 0,  // TODO: Not yet understood, defaulting to 0
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

    func trackAssetLiked(
        carouselId: String,
        asset: TimelineAssetDTO,
        externalUserId: String?
    ) async throws {
        // Build sessionId: carouselId~assetId
        let sessionId = "\(carouselId)~\(asset.id)"

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

    func trackCarouselLoaded(
        carouselId: String,
        assets: [TimelineAssetDTO],
        externalUserId: String?
    ) async throws {
        // sessionId is carouselId only for this event
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
        // sessionId is carouselId only for this event
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

    func trackAssetViewed(
        carouselId: String,
        asset: TimelineAssetDTO,
        position: Int,
        isInitialView: Bool,
        externalUserId: String?
    ) async throws {
        // Build sessionId: carouselId~assetId
        let sessionId = "\(carouselId)~\(asset.id)"

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

    func trackCarouselClicked(
        carouselId: String,
        clickedAsset: TimelineAssetDTO,
        allAssets: [TimelineAssetDTO],
        position: Int,
        externalUserId: String?
    ) async throws {
        // Build sessionId: carouselId~assetId
        let sessionId = "\(carouselId)~\(clickedAsset.id)"

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

    func trackCTAButtonClicked(
        carouselId: String,
        asset: TimelineAssetDTO,
        position: Int,
        targetUrl: String,
        terrificClickId: String,
        externalUserId: String?
    ) async throws {
        // Build sessionId: carouselId~assetId
        let sessionId = "\(carouselId)~\(asset.id)"

        let customProducts = mapCustomProducts(from: asset.products)

        let auxData = CTAButtonClickedAuxData(
            brandName: asset.brandName,
            campaignName: asset.campaignName,
            customProducts: customProducts,
            externalUserId: externalUserId,
            parentUrl: "",
            position: position,
            targetUrl: targetUrl,
            terrificClickId: terrificClickId,
            url: targetUrl,
            userAgent: configuration.userAgent
        )

        let body = AnalyticsEventRequestBody(
            name: .timelineCTAButtonClicked,
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
        // Build sessionId: carouselId~assetId
        let sessionId = "\(carouselId)~\(asset.id)"

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

    func trackPollVoted(
        carouselId: String,
        asset: TimelineAssetDTO,
        position: Int,
        pollId: String,
        pollAnswer: String,
        questionId: String,
        externalUserId: String?
    ) async throws {
        // Build sessionId: carouselId~assetId
        let sessionId = "\(carouselId)~\(asset.id)"

        let auxData = PollVotedAuxData(
            brandName: asset.brandName,
            campaignName: asset.campaignName,
            externalUserId: externalUserId,
            parentUrl: "",
            position: position,
            questionId: questionId,
            userAgent: configuration.userAgent
        )

        let body = PollVotedRequestBody(
            name: .timelinePollVoted,
            userId: configuration.userId,
            sessionId: sessionId,
            pollId: pollId,
            pollAnswer: pollAnswer,
            auxData: auxData
        )

        let request = PollVotedAPIRequest(
            storeId: configuration.storeId,
            requestBody: body
        )

        let _ = try await client.send(request)
    }

    func trackProductClicked(
        carouselId: String,
        asset: TimelineAssetDTO,
        product: ProductDTO,
        position: Int,
        terrificClickId: String,
        externalUserId: String?
    ) async throws {
        // Build sessionId: carouselId~assetId
        let sessionId = "\(carouselId)~\(asset.id)"

        let customProducts = mapCustomProducts(from: [product])

        let auxData = ProductClickedAuxData(
            id: product.id,
            name: product.name ?? "",
            description: product.description ?? "",
            externalURL: product.externalUrl ?? "",
            imageURL: product.imageUrl ?? "",
            price: product.formattedPrice ?? "",
            isCatalog: false,
            brandName: asset.brandName,
            campaignName: asset.campaignName,
            customProducts: customProducts,
            externalUserId: externalUserId,
            parentUrl: "",
            position: position,
            terrificClickId: terrificClickId,
            userAgent: configuration.userAgent
        )

        // Use first variant's id if available, otherwise empty string
        let variantId = product.variants?.first?.id ?? ""
        let items = [ProductClickedItem(productId: product.externalId ?? "", variantId: variantId)]

        let body = ProductClickedRequestBody(
            name: .timelineProductClicked,
            userId: configuration.userId,
            sessionId: sessionId,
            items: items,
            itemViewSource: "featuredItem",
            auxData: auxData
        )

        let request = ProductClickedAPIRequest(
            storeId: configuration.storeId,
            requestBody: body
        )

        let _ = try await client.send(request)
    }

    // MARK: - Mapping Helpers

    private func mapCustomProducts(from products: [ProductDTO]?) -> [AnalyticCustomProduct] {
        (products ?? []).map { product in
            AnalyticCustomProduct(
                name: product.name ?? "",
                price: product.formattedPrice ?? String(product.price ?? 0),
                currency: product.currency ?? "",
                description: product.description ?? "",
                externalURL: product.externalUrl ?? ""
            )
        }
    }

    private func mapAnalyticProducts(from products: [ProductDTO]?) -> [AnalyticProduct] {
        (products ?? []).map { product in
            AnalyticProduct(
                id: product.id,
                sku: product.sku ?? "",
                categories: product.categories ?? [],
                tags: []
            )
        }
    }

    private func assetTypeString(from type: AssetMediaTypeDTO) -> String {
        switch type {
        case .video: return "video"
        case .image: return "image"
        case .poll: return "poll"
        case .ad: return "ad"
        }
    }

    // MARK: - Sponsorship Events

    func trackCarouselSponsorshipClicked(
        carouselId: String,
        parentUrl: String?,
        externalUserId: String?,
        sponsorshipPlacement: CarouselSponsorshipPlacement,
        sponsorshipUrl: String?
    ) async throws {
        let sessionId = carouselId

        let auxData = CarouselSponsorshipClickedAuxData(
            parentUrl: "",
            externalUserId: externalUserId,
            sponsorshipPlacement: sponsorshipPlacement,
            sponsorshipUrl: sponsorshipUrl
        )

        let body = AnalyticsEventRequestBody(
            name: .timelineCarouselSponsorshipClicked,
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

    func trackAssetSponsorshipClicked(
        carouselId: String,
        asset: TimelineAssetDTO,
        externalUserId: String?,
        sponsorshipPlacement: AssetSponsorshipPlacement,
        sponsorshipPosition: SponsorshipPosition?,
        clickPosition: SponsorshipClickPosition?,
        sponsorshipUrl: String?
    ) async throws {
        let sessionId = "\(carouselId)~\(asset.id)"

        let auxData = AssetSponsorshipClickedAuxData(
            parentUrl: "",
            externalUserId: externalUserId,
            sponsorshipPlacement: sponsorshipPlacement,
            sponsorshipPosition: sponsorshipPosition,
            clickPosition: clickPosition,
            sponsorshipUrl: sponsorshipUrl
        )

        let body = AnalyticsEventRequestBody(
            name: .timelineAssetSponsorshipClicked,
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
