//
//  AnalyticsServiceImpl+Interaction.swift
//  TerrificCarouselSDK
//

import Foundation

// MARK: - User Interaction Events (CTA, Poll, Product, Sponsorship)
extension AnalyticsServiceImpl {

    func trackCTAButtonClicked(
        carouselId: String,
        asset: TimelineAssetDTO,
        position: Int,
        targetUrl: String,
        terrificClickId: String,
        externalUserId: String?
    ) async throws {
        let sessionId = sessionId(carouselId: carouselId, assetId: asset.id)

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

    func trackPollVoted(
        carouselId: String,
        asset: TimelineAssetDTO,
        position: Int,
        pollId: String,
        pollAnswer: String,
        questionId: String,
        externalUserId: String?
    ) async throws {
        let sessionId = sessionId(carouselId: carouselId, assetId: asset.id)

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
        let sessionId = sessionId(carouselId: carouselId, assetId: asset.id)

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
        let sessionId = sessionId(carouselId: carouselId, assetId: asset.id)

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
