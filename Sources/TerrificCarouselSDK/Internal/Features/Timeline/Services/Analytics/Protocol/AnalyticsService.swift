//
//  AnalyticsService.swift
//  CarouselDemo
//

import Foundation

// MARK: - AnalyticsService
/// Protocol for sending analytics events
protocol AnalyticsService {
    /// Track when vertical carousel (timeline) appears on screen
    /// - Parameters:
    ///   - carouselId: The carousel/timeline identifier (used as sessionId)
    ///   - parentUrl: The parent URL context
    ///   - externalUserId: Optional external user ID if present
    func trackTimelineOpened(
        carouselId: String,
        parentUrl: String,
        externalUserId: String?
    ) async throws

    /// Track when user closes the timeline detail view
    /// - Parameters:
    ///   - carouselId: The carousel/timeline identifier (used as sessionId)
    ///   - parentUrl: The parent URL context
    ///   - openDurationMs: Total time the timeline was open in milliseconds
    ///   - externalUserId: Optional external user ID if present
    func trackTimelineClosed(
        carouselId: String,
        parentUrl: String,
        openDurationMs: Int,
        externalUserId: String?
    ) async throws

    /// Track when user starts viewing an asset in the detail view
    /// - Parameters:
    ///   - carouselId: The carousel/timeline identifier
    ///   - asset: The asset being viewed
    ///   - position: The asset position
    ///   - externalUserId: Optional external user ID if present
    func trackAssetViewStarted(
        carouselId: String,
        asset: TimelineAssetDTO,
        position: Int,
        externalUserId: String?
    ) async throws

    /// Track when user stops viewing an asset in the detail view
    /// - Parameters:
    ///   - carouselId: The carousel/timeline identifier
    ///   - asset: The asset that was viewed
    ///   - position: The asset position
    ///   - viewDurationMs: How long the asset was viewed in milliseconds
    ///   - externalUserId: Optional external user ID if present
    func trackAssetViewEnded(
        carouselId: String,
        asset: TimelineAssetDTO,
        position: Int,
        viewDurationMs: Int,
        externalUserId: String?
    ) async throws

    /// Track when user likes an asset in the carousel
    /// - Parameters:
    ///   - carouselId: The carousel identifier
    ///   - asset: The liked asset
    ///   - externalUserId: Optional external user ID if present
    func trackAssetLiked(
        carouselId: String,
        asset: TimelineAssetDTO,
        externalUserId: String?
    ) async throws

    /// Track when carousel page is loaded
    /// - Parameters:
    ///   - carouselId: The carousel identifier
    ///   - assets: Array of assets in the loaded page
    ///   - externalUserId: Optional external user ID if present
    func trackCarouselLoaded(
        carouselId: String,
        assets: [TimelineAssetDTO],
        externalUserId: String?
    ) async throws

    /// Track when carousel view appears on screen
    /// - Parameters:
    ///   - carouselId: The carousel identifier
    ///   - assets: Array of assets currently in the carousel
    ///   - externalUserId: Optional external user ID if present
    func trackCarouselViewed(
        carouselId: String,
        assets: [TimelineAssetDTO],
        externalUserId: String?
    ) async throws

    /// Track when an individual asset appears on screen
    /// - Parameters:
    ///   - carouselId: The carousel identifier
    ///   - asset: The viewed asset
    ///   - position: The asset position in the list
    ///   - isInitialView: True if the asset was visible from the start, false if scrolled into view
    ///   - externalUserId: Optional external user ID if present
    func trackAssetViewed(
        carouselId: String,
        asset: TimelineAssetDTO,
        position: Int,
        isInitialView: Bool,
        externalUserId: String?
    ) async throws

    /// Track when user clicks on an asset to open detail view
    /// - Parameters:
    ///   - carouselId: The carousel identifier
    ///   - clickedAsset: The clicked asset
    ///   - allAssets: All assets currently in the carousel
    ///   - position: The clicked asset position
    ///   - externalUserId: Optional external user ID if present
    func trackCarouselClicked(
        carouselId: String,
        clickedAsset: TimelineAssetDTO,
        allAssets: [TimelineAssetDTO],
        position: Int,
        externalUserId: String?
    ) async throws

    /// Track when user clicks a CTA button in timeline detail view
    /// - Parameters:
    ///   - carouselId: The carousel identifier
    ///   - asset: The asset containing the CTA button
    ///   - position: The asset position
    ///   - targetUrl: The URL the CTA button navigates to
    ///   - externalUserId: Optional external user ID if present
    func trackCTAButtonClicked(
        carouselId: String,
        asset: TimelineAssetDTO,
        position: Int,
        targetUrl: String,
        externalUserId: String?
    ) async throws

    /// Track when user shares an asset from the timeline
    /// - Parameters:
    ///   - carouselId: The carousel identifier
    ///   - asset: The asset being shared
    ///   - position: The asset position
    ///   - externalUserId: Optional external user ID if present
    func trackAssetShared(
        carouselId: String,
        asset: TimelineAssetDTO,
        position: Int,
        externalUserId: String?
    ) async throws

    /// Track when user votes on a poll within a timeline asset
    /// - Parameters:
    ///   - carouselId: The carousel identifier
    ///   - asset: The asset containing the poll
    ///   - position: The asset position
    ///   - pollId: The poll identifier
    ///   - pollAnswer: The selected answer text
    ///   - questionId: The question identifier
    ///   - externalUserId: Optional external user ID if present
    func trackPollVoted(
        carouselId: String,
        asset: TimelineAssetDTO,
        position: Int,
        pollId: String,
        pollAnswer: String,
        questionId: String,
        externalUserId: String?
    ) async throws
}
