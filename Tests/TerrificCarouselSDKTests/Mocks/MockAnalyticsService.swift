//
//  MockAnalyticsService.swift
//  TerrificCarouselSDKTests
//

import Foundation
@testable import TerrificCarouselSDK

/// Mock analytics service for testing
final class MockAnalyticsService: AnalyticsService {

    // MARK: - Call Tracking
    struct TimelineOpenedCall {
        let carouselId: String
        let parentUrl: String
        let externalUserId: String?
    }

    struct TimelineClosedCall {
        let carouselId: String
        let parentUrl: String
        let totalOpenDurationMs: Int
        let activeViewDurationMs: Int
        let externalUserId: String?
    }

    struct AssetViewStartedCall {
        let carouselId: String
        let asset: TimelineAssetDTO
        let position: Int
        let externalUserId: String?
    }

    struct AssetViewEndedCall {
        let carouselId: String
        let asset: TimelineAssetDTO
        let position: Int
        let viewDurationMs: Int
        let netoWatchTimeMs: Int
        let externalUserId: String?
    }

    struct AssetLikedCall {
        let carouselId: String
        let asset: TimelineAssetDTO
        let externalUserId: String?
    }

    struct CarouselLoadedCall {
        let carouselId: String
        let assets: [TimelineAssetDTO]
        let externalUserId: String?
    }

    struct CarouselViewedCall {
        let carouselId: String
        let assets: [TimelineAssetDTO]
        let externalUserId: String?
    }

    struct AssetViewedCall {
        let carouselId: String
        let asset: TimelineAssetDTO
        let position: Int
        let isInitialView: Bool
        let externalUserId: String?
    }

    struct CarouselClickedCall {
        let carouselId: String
        let clickedAsset: TimelineAssetDTO
        let allAssets: [TimelineAssetDTO]
        let position: Int
        let externalUserId: String?
    }

    struct CTAButtonClickedCall {
        let carouselId: String
        let asset: TimelineAssetDTO
        let position: Int
        let targetUrl: String
        let terrificClickId: String
        let externalUserId: String?
    }

    struct AssetSharedCall {
        let carouselId: String
        let asset: TimelineAssetDTO
        let position: Int
        let externalUserId: String?
    }

    struct PollVotedCall {
        let carouselId: String
        let asset: TimelineAssetDTO
        let position: Int
        let pollId: String
        let pollAnswer: String
        let questionId: String
        let externalUserId: String?
    }

    struct ProductClickedCall {
        let carouselId: String
        let asset: TimelineAssetDTO
        let product: ProductDTO
        let position: Int
        let terrificClickId: String
        let externalUserId: String?
    }

    struct CarouselSponsorshipClickedCall {
        let carouselId: String
        let parentUrl: String?
        let externalUserId: String?
        let sponsorshipPlacement: CarouselSponsorshipPlacement
        let sponsorshipUrl: String?
    }

    struct AssetSponsorshipClickedCall {
        let carouselId: String
        let asset: TimelineAssetDTO
        let externalUserId: String?
        let sponsorshipPlacement: AssetSponsorshipPlacement
        let sponsorshipPosition: SponsorshipPosition?
        let clickPosition: SponsorshipClickPosition?
        let sponsorshipUrl: String?
    }

    // MARK: - Recorded Calls
    private(set) var timelineOpenedCalls: [TimelineOpenedCall] = []
    private(set) var timelineClosedCalls: [TimelineClosedCall] = []
    private(set) var assetViewStartedCalls: [AssetViewStartedCall] = []
    private(set) var assetViewEndedCalls: [AssetViewEndedCall] = []
    private(set) var assetLikedCalls: [AssetLikedCall] = []
    private(set) var carouselLoadedCalls: [CarouselLoadedCall] = []
    private(set) var carouselViewedCalls: [CarouselViewedCall] = []
    private(set) var assetViewedCalls: [AssetViewedCall] = []
    private(set) var carouselClickedCalls: [CarouselClickedCall] = []
    private(set) var ctaButtonClickedCalls: [CTAButtonClickedCall] = []
    private(set) var assetSharedCalls: [AssetSharedCall] = []
    private(set) var pollVotedCalls: [PollVotedCall] = []
    private(set) var productClickedCalls: [ProductClickedCall] = []
    private(set) var carouselSponsorshipClickedCalls: [CarouselSponsorshipClickedCall] = []
    private(set) var assetSponsorshipClickedCalls: [AssetSponsorshipClickedCall] = []

    // MARK: - Error Stubbing
    var stubbedError: Error?

    // MARK: - AnalyticsService Implementation

    func trackTimelineOpened(carouselId: String, parentUrl: String, externalUserId: String?) async throws {
        if let error = stubbedError { throw error }
        timelineOpenedCalls.append(TimelineOpenedCall(carouselId: carouselId, parentUrl: parentUrl, externalUserId: externalUserId))
    }

    func trackTimelineClosed(carouselId: String, parentUrl: String, totalOpenDurationMs: Int, activeViewDurationMs: Int, externalUserId: String?) async throws {
        if let error = stubbedError { throw error }
        timelineClosedCalls.append(TimelineClosedCall(carouselId: carouselId, parentUrl: parentUrl, totalOpenDurationMs: totalOpenDurationMs, activeViewDurationMs: activeViewDurationMs, externalUserId: externalUserId))
    }

    func trackAssetViewStarted(carouselId: String, asset: TimelineAssetDTO, position: Int, externalUserId: String?) async throws {
        if let error = stubbedError { throw error }
        assetViewStartedCalls.append(AssetViewStartedCall(carouselId: carouselId, asset: asset, position: position, externalUserId: externalUserId))
    }

    func trackAssetViewEnded(carouselId: String, asset: TimelineAssetDTO, position: Int, viewDurationMs: Int, netoWatchTimeMs: Int, externalUserId: String?) async throws {
        if let error = stubbedError { throw error }
        assetViewEndedCalls.append(AssetViewEndedCall(carouselId: carouselId, asset: asset, position: position, viewDurationMs: viewDurationMs, netoWatchTimeMs: netoWatchTimeMs, externalUserId: externalUserId))
    }

    func trackAssetLiked(carouselId: String, asset: TimelineAssetDTO, externalUserId: String?) async throws {
        if let error = stubbedError { throw error }
        assetLikedCalls.append(AssetLikedCall(carouselId: carouselId, asset: asset, externalUserId: externalUserId))
    }

    func trackCarouselLoaded(carouselId: String, assets: [TimelineAssetDTO], externalUserId: String?) async throws {
        if let error = stubbedError { throw error }
        carouselLoadedCalls.append(CarouselLoadedCall(carouselId: carouselId, assets: assets, externalUserId: externalUserId))
    }

    func trackCarouselViewed(carouselId: String, assets: [TimelineAssetDTO], externalUserId: String?) async throws {
        if let error = stubbedError { throw error }
        carouselViewedCalls.append(CarouselViewedCall(carouselId: carouselId, assets: assets, externalUserId: externalUserId))
    }

    func trackAssetViewed(carouselId: String, asset: TimelineAssetDTO, position: Int, isInitialView: Bool, externalUserId: String?) async throws {
        if let error = stubbedError { throw error }
        assetViewedCalls.append(AssetViewedCall(carouselId: carouselId, asset: asset, position: position, isInitialView: isInitialView, externalUserId: externalUserId))
    }

    func trackCarouselClicked(carouselId: String, clickedAsset: TimelineAssetDTO, allAssets: [TimelineAssetDTO], position: Int, externalUserId: String?) async throws {
        if let error = stubbedError { throw error }
        carouselClickedCalls.append(CarouselClickedCall(carouselId: carouselId, clickedAsset: clickedAsset, allAssets: allAssets, position: position, externalUserId: externalUserId))
    }

    func trackCTAButtonClicked(carouselId: String, asset: TimelineAssetDTO, position: Int, targetUrl: String, terrificClickId: String, externalUserId: String?) async throws {
        if let error = stubbedError { throw error }
        ctaButtonClickedCalls.append(CTAButtonClickedCall(carouselId: carouselId, asset: asset, position: position, targetUrl: targetUrl, terrificClickId: terrificClickId, externalUserId: externalUserId))
    }

    func trackAssetShared(carouselId: String, asset: TimelineAssetDTO, position: Int, externalUserId: String?) async throws {
        if let error = stubbedError { throw error }
        assetSharedCalls.append(AssetSharedCall(carouselId: carouselId, asset: asset, position: position, externalUserId: externalUserId))
    }

    func trackPollVoted(carouselId: String, asset: TimelineAssetDTO, position: Int, pollId: String, pollAnswer: String, questionId: String, externalUserId: String?) async throws {
        if let error = stubbedError { throw error }
        pollVotedCalls.append(PollVotedCall(carouselId: carouselId, asset: asset, position: position, pollId: pollId, pollAnswer: pollAnswer, questionId: questionId, externalUserId: externalUserId))
    }

    func trackProductClicked(carouselId: String, asset: TimelineAssetDTO, product: ProductDTO, position: Int, terrificClickId: String, externalUserId: String?) async throws {
        if let error = stubbedError { throw error }
        productClickedCalls.append(ProductClickedCall(carouselId: carouselId, asset: asset, product: product, position: position, terrificClickId: terrificClickId, externalUserId: externalUserId))
    }

    func trackCarouselSponsorshipClicked(carouselId: String, parentUrl: String?, externalUserId: String?, sponsorshipPlacement: CarouselSponsorshipPlacement, sponsorshipUrl: String?) async throws {
        if let error = stubbedError { throw error }
        carouselSponsorshipClickedCalls.append(CarouselSponsorshipClickedCall(carouselId: carouselId, parentUrl: parentUrl, externalUserId: externalUserId, sponsorshipPlacement: sponsorshipPlacement, sponsorshipUrl: sponsorshipUrl))
    }

    func trackAssetSponsorshipClicked(carouselId: String, asset: TimelineAssetDTO, externalUserId: String?, sponsorshipPlacement: AssetSponsorshipPlacement, sponsorshipPosition: SponsorshipPosition?, clickPosition: SponsorshipClickPosition?, sponsorshipUrl: String?) async throws {
        if let error = stubbedError { throw error }
        assetSponsorshipClickedCalls.append(AssetSponsorshipClickedCall(carouselId: carouselId, asset: asset, externalUserId: externalUserId, sponsorshipPlacement: sponsorshipPlacement, sponsorshipPosition: sponsorshipPosition, clickPosition: clickPosition, sponsorshipUrl: sponsorshipUrl))
    }

    // MARK: - Reset
    func reset() {
        timelineOpenedCalls = []
        timelineClosedCalls = []
        assetViewStartedCalls = []
        assetViewEndedCalls = []
        assetLikedCalls = []
        carouselLoadedCalls = []
        carouselViewedCalls = []
        assetViewedCalls = []
        carouselClickedCalls = []
        ctaButtonClickedCalls = []
        assetSharedCalls = []
        pollVotedCalls = []
        productClickedCalls = []
        carouselSponsorshipClickedCalls = []
        assetSponsorshipClickedCalls = []
        stubbedError = nil
    }
}
