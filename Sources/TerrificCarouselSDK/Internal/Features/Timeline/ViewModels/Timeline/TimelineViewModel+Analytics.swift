//
//  TimelineViewModel+Analytics.swift
//  TerrificCarouselSDK
//

import Foundation

// MARK: - Analytics Tracking
extension TimelineViewModel {

    /// Call when an asset card appears on screen
    func handleAssetAppeared(_ asset: TimelineAssetDTO) {
        guard !viewedAssetIds.contains(asset.id) else { return }
        viewedAssetIds.insert(asset.id)

        let isInitialView = isInitialCarouselState
        analyticDelegate?.viewModel(self, didViewAsset: asset, at: asset.position, isInitialView: isInitialView)
    }

    /// Call when the carousel view appears on screen
    func handleCarouselViewed() {
        guard case .content(let assets) = state, !assets.isEmpty else { return }
        analyticDelegate?.viewModel(self, didViewCarouselWithAssets: assets)
    }

    /// Call when user likes an asset
    func handleAssetLiked(_ asset: TimelineAssetDTO) {
        analyticDelegate?.viewModel(self, didLikeAsset: asset)
        objectWillChange.send()
    }

    /// Call when timeline detail view appears on screen
    func handleDetailOpened() {
        // Track when detail view was opened
        timelineDetailsOpenedTime = Date()
        detailBackgroundDuration = 0

        // Get parentUrl from current asset
        let parentUrl = getAsset(at: currentPageIndex)?.parentUrl ?? ""
        analyticDelegate?.viewModel(self, didOpenDetailWithParentUrl: parentUrl)
    }

    /// Call when timeline detail view is closed
    func handleDetailClosed() {
        guard let openedTime = timelineDetailsOpenedTime else { return }

        // Calculate total wall-clock duration
        let totalOpenDurationMs = Int(Date().timeIntervalSince(openedTime) * 1000)
        // Subtract background time for active duration
        let activeViewDurationMs = max(0, totalOpenDurationMs - Int(detailBackgroundDuration * 1000))

        // Get parentUrl from current asset
        let parentUrl = getAsset(at: currentPageIndex)?.parentUrl ?? ""

        // Reset tracking state
        timelineDetailsOpenedTime = nil
        detailBackgroundDuration = 0

        analyticDelegate?.viewModel(
            self,
            didCloseDetailWithParentUrl: parentUrl,
            totalOpenDurationMs: totalOpenDurationMs,
            activeViewDurationMs: activeViewDurationMs
        )
    }

    /// Call when user starts viewing an asset in detail view
    func handleAssetViewStarted(at index: Int) {
        // End previous view if exists
        handleAssetViewEnded()

        guard let asset = getAsset(at: index) else { return }

        // Track start time for duration calculation
        currentViewStartTime = Date()
        currentViewAssetIndex = index
        assetViewBackgroundDuration = 0

        analyticDelegate?.viewModel(self, didStartViewingAsset: asset, at: asset.position)
    }

    /// Call when user stops viewing an asset in detail view
    func handleAssetViewEnded() {
        guard let startTime = currentViewStartTime,
              let assetIndex = currentViewAssetIndex,
              let asset = getAsset(at: assetIndex) else {
            return
        }

        // Total wall-clock duration
        let viewDurationMs = Int(Date().timeIntervalSince(startTime) * 1000)
        // Subtract background time for net watch time
        let netoWatchTimeMs = max(0, viewDurationMs - Int(assetViewBackgroundDuration * 1000))

        // Reset tracking state
        currentViewStartTime = nil
        currentViewAssetIndex = nil
        assetViewBackgroundDuration = 0

        analyticDelegate?.viewModel(
            self,
            didEndViewingAsset: asset,
            at: asset.position,
            viewDurationMs: viewDurationMs,
            netoWatchTimeMs: netoWatchTimeMs
        )
    }

    /// Notifies delegate about CTA button tap
    func handleCtaButtonTap(asset: TimelineAssetDTO, url: URL?) {
        guard let url else { return }
        analyticDelegate?.viewModel(self, didClickCTAButton: asset, at: asset.position, targetUrl: url.absoluteString)
    }

    /// Notifies delegate about product CTA tap
    func handleProductCtaTap(product: ProductDTO, asset: TimelineAssetDTO, url: URL?) {
        guard let url else { return }
        analyticDelegate?.viewModel(self, didClickProduct: product, inAsset: asset, targetUrl: url.absoluteString)
    }

    /// Tracks when user shares an asset
    func handleAssetShared(_ asset: TimelineAssetDTO) {
        analyticDelegate?.viewModel(self, didShareAsset: asset, at: asset.position)
    }

    /// Tracks when user clicks a sponsorship element in the horizontal carousel
    func handleCarouselSponsorshipClicked(placement: CarouselSponsorshipPlacement, sponsorshipUrl: String?) {
        analyticDelegate?.viewModel(self, didClickCarouselSponsorship: placement, sponsorshipUrl: sponsorshipUrl)
    }

    /// Tracks when user clicks a sponsorship element in the vertical carousel
    func handleAssetSponsorshipClicked(
        asset: TimelineAssetDTO,
        placement: AssetSponsorshipPlacement,
        position: SponsorshipPosition?,
        clickPosition: SponsorshipClickPosition?,
        sponsorshipUrl: String?
    ) {
        analyticDelegate?.viewModel(
            self,
            didClickAssetSponsorship: asset,
            sponsorshipPlacement: placement,
            sponsorshipPosition: position,
            clickPosition: clickPosition,
            sponsorshipUrl: sponsorshipUrl
        )
    }

    /// Notifies delegate about newly loaded assets
    func notifyAssetsLoaded(_ assets: [TimelineAssetDTO]) {
        guard !assets.isEmpty else { return }
        analyticDelegate?.viewModel(self, didLoadAssets: assets)
    }
}
