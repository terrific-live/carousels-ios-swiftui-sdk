//
//  TimelineCoordinator+Analytics.swift
//  TerrificCarouselSDK
//

import SwiftUI

// MARK: - TimelineViewModelAnalyticDelegate
extension TimelineCoordinator: TimelineViewModelAnalyticDelegate {

    func viewModel(
        _ viewModel: TimelineViewModel,
        didViewAsset asset: TimelineAssetDTO,
        at position: Int,
        isInitialView: Bool
    ) {
        emit(.assetViewed(
            asset: CarouselAsset(from: asset),
            position: position,
            isInitialView: isInitialView
        ))

        sendAnalyticsIfEnabled("AssetViewed") { [analyticsService, carouselId] in
            try await analyticsService?.trackAssetViewed(
                carouselId: carouselId,
                asset: asset,
                position: position,
                isInitialView: isInitialView,
                externalUserId: nil
            )
        }
    }

    func viewModel(
        _ viewModel: TimelineViewModel,
        didLoadAssets assets: [TimelineAssetDTO]
    ) {
        // Only track CarouselLoaded for feed, not detail
        guard viewModel === _feedViewModel else { return }

        emit(.carouselLoaded(assets: assets.map { CarouselAsset(from: $0) }))

        sendAnalyticsIfEnabled("CarouselLoaded") { [analyticsService, carouselId] in
            try await analyticsService?.trackCarouselLoaded(
                carouselId: carouselId,
                assets: assets,
                externalUserId: nil
            )
        }
    }

    func viewModel(
        _ viewModel: TimelineViewModel,
        didViewCarouselWithAssets assets: [TimelineAssetDTO]
    ) {
        emit(.carouselViewed(assets: assets.map { CarouselAsset(from: $0) }))

        sendAnalyticsIfEnabled("CarouselViewed") { [analyticsService, carouselId] in
            try await analyticsService?.trackCarouselViewed(
                carouselId: carouselId,
                assets: assets,
                externalUserId: nil
            )
        }
    }

    func viewModel(
        _ viewModel: TimelineViewModel,
        didLikeAsset asset: TimelineAssetDTO
    ) {
        // Toggle like state in storage
        let wasLiked = likeStorage?.isLiked(asset.id) ?? false
        let isNowLiked = !wasLiked
        likeStorage?.setLiked(asset.id, isLiked: isNowLiked)

        // Only emit analytics event when liking (not unliking)
        guard isNowLiked else { return }

        emit(.assetLiked(asset: CarouselAsset(from: asset)))

        sendAnalyticsIfEnabled("AssetLiked") { [analyticsService, carouselId] in
            try await analyticsService?.trackAssetLiked(
                carouselId: carouselId,
                asset: asset,
                externalUserId: nil
            )
        }
    }

    func viewModel(
        _ viewModel: TimelineViewModel,
        didOpenDetailWithParentUrl parentUrl: String
    ) {
        emit(.timelineOpened(parentUrl: parentUrl))

        sendAnalyticsIfEnabled("TimelineOpened") { [analyticsService, carouselId] in
            try await analyticsService?.trackTimelineOpened(
                carouselId: carouselId,
                parentUrl: parentUrl,
                externalUserId: nil
            )
        }
    }

    func viewModel(
        _ viewModel: TimelineViewModel,
        didStartViewingAsset asset: TimelineAssetDTO,
        at position: Int
    ) {
        emit(.assetViewStarted(asset: CarouselAsset(from: asset), position: position))

        sendAnalyticsIfEnabled("AssetViewStarted") { [analyticsService, carouselId] in
            try await analyticsService?.trackAssetViewStarted(
                carouselId: carouselId,
                asset: asset,
                position: position,
                externalUserId: nil
            )
        }
    }

    func viewModel(
        _ viewModel: TimelineViewModel,
        didEndViewingAsset asset: TimelineAssetDTO,
        at position: Int,
        viewDurationMs: Int,
        netoWatchTimeMs: Int
    ) {
        emit(.assetViewEnded(
            asset: CarouselAsset(from: asset),
            position: position,
            durationMs: viewDurationMs
        ))

        sendAnalyticsIfEnabled("AssetViewEnded") { [analyticsService, carouselId] in
            try await analyticsService?.trackAssetViewEnded(
                carouselId: carouselId,
                asset: asset,
                position: position,
                viewDurationMs: viewDurationMs,
                netoWatchTimeMs: netoWatchTimeMs,
                externalUserId: nil
            )
        }
    }

    func viewModel(
        _ viewModel: TimelineViewModel,
        didCloseDetailWithParentUrl parentUrl: String,
        totalOpenDurationMs: Int,
        activeViewDurationMs: Int
    ) {
        emit(.timelineClosed(parentUrl: parentUrl, durationMs: totalOpenDurationMs))

        sendAnalyticsIfEnabled("TimelineClosed") { [analyticsService, carouselId] in
            try await analyticsService?.trackTimelineClosed(
                carouselId: carouselId,
                parentUrl: parentUrl,
                totalOpenDurationMs: totalOpenDurationMs,
                activeViewDurationMs: activeViewDurationMs,
                externalUserId: nil
            )
        }
    }

    func viewModel(
        _ viewModel: TimelineViewModel,
        didClickCTAButton asset: TimelineAssetDTO,
        at position: Int,
        targetUrl: String
    ) {
        // Generate unique terrificClickId
        let terrificClickId = UUID().uuidString.lowercased()

        // Build modified URL with terrificClickId query parameter
        let modifiedUrl = buildUrlWithTerrificClickId(targetUrl, terrificClickId: terrificClickId)

        emit(.ctaButtonClicked(
            asset: CarouselAsset(from: asset),
            position: position,
            targetUrl: targetUrl
        ))

        sendAnalyticsIfEnabled("CTAButtonClicked") { [analyticsService, carouselId] in
            try await analyticsService?.trackCTAButtonClicked(
                carouselId: carouselId,
                asset: asset,
                position: position,
                targetUrl: targetUrl,
                terrificClickId: terrificClickId,
                externalUserId: nil
            )
        }

        // Open the modified URL
        if let url = URL(string: modifiedUrl) {
            UIApplication.shared.open(url)
        }
    }

    func viewModel(
        _ viewModel: TimelineViewModel,
        didShareAsset asset: TimelineAssetDTO,
        at position: Int
    ) {
        emit(.assetShared(asset: CarouselAsset(from: asset), position: position))

        sendAnalyticsIfEnabled("AssetShared") { [analyticsService, carouselId] in
            try await analyticsService?.trackAssetShared(
                carouselId: carouselId,
                asset: asset,
                position: position,
                externalUserId: nil
            )
        }
    }

    func viewModel(
        _ viewModel: TimelineViewModel,
        didClickProduct product: ProductDTO,
        inAsset asset: TimelineAssetDTO,
        targetUrl: String
    ) {
        // Generate unique terrificClickId
        let terrificClickId = UUID().uuidString.lowercased()

        // Build modified URL with terrificClickId query parameter
        let modifiedUrl = buildUrlWithTerrificClickId(targetUrl, terrificClickId: terrificClickId)

        emit(.productClicked(
            asset: CarouselAsset(from: asset),
            product: CarouselProduct(from: product),
            position: asset.position,
            targetUrl: targetUrl
        ))

        sendAnalyticsIfEnabled("ProductClicked") { [analyticsService, carouselId] in
            try await analyticsService?.trackProductClicked(
                carouselId: carouselId,
                asset: asset,
                product: product,
                position: asset.position,
                terrificClickId: terrificClickId,
                externalUserId: nil
            )
        }

        // Open the modified URL
        if let url = URL(string: modifiedUrl) {
            UIApplication.shared.open(url)
        }
    }

    func viewModel(
        _ viewModel: TimelineViewModel,
        didClickCarouselSponsorship sponsorshipPlacement: CarouselSponsorshipPlacement,
        sponsorshipUrl: String?
    ) {
        let parentUrl = feedViewModel.carouselItems.compactMap { item -> String? in
            if case .content(let asset, _) = item { return asset.parentUrl }
            return nil
        }.first

        emit(.carouselSponsorshipClicked(
            sponsorshipPlacement: sponsorshipPlacement.rawValue,
            sponsorshipUrl: sponsorshipUrl
        ))

        sendAnalyticsIfEnabled("CarouselSponsorshipClicked") { [analyticsService, carouselId] in
            try await analyticsService?.trackCarouselSponsorshipClicked(
                carouselId: carouselId,
                parentUrl: parentUrl,
                externalUserId: nil,
                sponsorshipPlacement: sponsorshipPlacement,
                sponsorshipUrl: sponsorshipUrl
            )
        }
    }

    func viewModel(
        _ viewModel: TimelineViewModel,
        didClickAssetSponsorship asset: TimelineAssetDTO,
        sponsorshipPlacement: AssetSponsorshipPlacement,
        sponsorshipPosition: SponsorshipPosition?,
        clickPosition: SponsorshipClickPosition?,
        sponsorshipUrl: String?
    ) {
        emit(.assetSponsorshipClicked(
            asset: CarouselAsset(from: asset),
            sponsorshipPlacement: sponsorshipPlacement.rawValue,
            sponsorshipPosition: sponsorshipPosition?.rawValue,
            clickPosition: clickPosition?.rawValue,
            sponsorshipUrl: sponsorshipUrl
        ))

        sendAnalyticsIfEnabled("AssetSponsorshipClicked") { [analyticsService, carouselId] in
            try await analyticsService?.trackAssetSponsorshipClicked(
                carouselId: carouselId,
                asset: asset,
                externalUserId: nil,
                sponsorshipPlacement: sponsorshipPlacement,
                sponsorshipPosition: sponsorshipPosition,
                clickPosition: clickPosition,
                sponsorshipUrl: sponsorshipUrl
            )
        }
    }

    /// Track when user clicks on an asset to open detail view
    /// Called from presentDetail - not a delegate method
    func trackCarouselClicked(at position: Int) {
        let carouselItems = feedViewModel.carouselItems
        let assets = carouselItems.compactMap { item -> TimelineAssetDTO? in
            if case .content(let asset, _) = item {
                return asset
            }
            return nil
        }

        guard position < assets.count else { return }
        let clickedAsset = assets[position]

        emit(.carouselClicked(
            asset: CarouselAsset(from: clickedAsset),
            position: clickedAsset.position
        ))

        sendAnalyticsIfEnabled("CarouselClicked") { [analyticsService, carouselId] in
            try await analyticsService?.trackCarouselClicked(
                carouselId: carouselId,
                clickedAsset: clickedAsset,
                allAssets: assets,
                position: clickedAsset.position,
                externalUserId: nil
            )
        }
    }
}

// MARK: - PollViewModelAnalyticDelegate
extension TimelineCoordinator: PollViewModelAnalyticDelegate {

    func pollViewModel(
        _ viewModel: PollViewModel,
        didVoteForAssetId assetId: String,
        pollId: String,
        pollAnswer: String,
        questionId: String
    ) {
        guard let asset = findAsset(by: assetId) else { return }

        emit(.pollVoted(
            asset: CarouselAsset(from: asset),
            position: asset.position,
            pollId: pollId,
            answer: pollAnswer
        ))

        sendAnalyticsIfEnabled("PollVoted") { [analyticsService, carouselId] in
            try await analyticsService?.trackPollVoted(
                carouselId: carouselId,
                asset: asset,
                position: asset.position,
                pollId: pollId,
                pollAnswer: pollAnswer,
                questionId: questionId,
                externalUserId: nil
            )
        }
    }
}

// MARK: - Private Analytics Helpers
private extension TimelineCoordinator {

    func findAsset(by assetId: String) -> TimelineAssetDTO? {
        // Search in feed view model
        for item in _feedViewModel?.carouselItems ?? [] {
            if case .content(let asset, _) = item, asset.id == assetId {
                return asset
            }
        }
        return nil
    }

    /// Emits an analytics event to SDK users
    func emit(_ event: CarouselAnalyticsEvent) {
        onAnalyticsEvent?(event)
    }

    /// Sends analytics event to service if analytics is enabled
    /// - Parameters:
    ///   - eventName: Name of the event for logging
    ///   - operation: Async operation that sends the analytics
    func sendAnalyticsIfEnabled(_ eventName: String, operation: @escaping () async throws -> Void) {
        Task {
            guard AnalyticsConfiguration.isAnalyticsEnabled else {
                AnalyticsLogger.info("\(eventName) skipped (debug mode)")
                return
            }

            do {
                try await operation()
                AnalyticsLogger.success(eventName)
            } catch {
                AnalyticsLogger.error(eventName, errorMessage: "\(error.localizedDescription)")
            }
        }
    }

    /// Builds a URL with terrificClickId query parameter appended
    /// Format: terrificClickId=<terrificClickId>_<storeId>
    func buildUrlWithTerrificClickId(_ urlString: String, terrificClickId: String) -> String {
        guard var urlComponents = URLComponents(string: urlString) else {
            return urlString
        }

        let clickIdValue = "\(terrificClickId)_\(storeId)"
        let queryItem = URLQueryItem(name: "terrificClickId", value: clickIdValue)

        var queryItems = urlComponents.queryItems ?? []
        queryItems.append(queryItem)
        urlComponents.queryItems = queryItems

        return urlComponents.url?.absoluteString ?? urlString
    }
}
