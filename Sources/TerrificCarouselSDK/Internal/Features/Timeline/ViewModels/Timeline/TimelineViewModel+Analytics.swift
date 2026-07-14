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
        detailSessionTracker.open()

        let parentUrl = getAsset(at: currentPageIndex)?.parentUrl ?? ""
        analyticDelegate?.viewModel(self, didOpenDetailWithParentUrl: parentUrl)
    }

    /// Call when timeline detail view is closed
    func handleDetailClosed() {
        guard let result = detailSessionTracker.close() else { return }

        let parentUrl = getAsset(at: currentPageIndex)?.parentUrl ?? ""

        analyticDelegate?.viewModel(
            self,
            didCloseDetailWithParentUrl: parentUrl,
            totalOpenDurationMs: result.totalOpenDurationMs,
            activeViewDurationMs: result.activeViewDurationMs
        )
    }

    /// Call when user starts viewing an asset in detail view
    func handleAssetViewStarted(at index: Int) {
        // End previous view if exists
        handleAssetViewEnded()

        guard let asset = getAsset(at: index) else { return }

        assetViewTracker.start(at: index)
        analyticDelegate?.viewModel(self, didStartViewingAsset: asset, at: asset.position)
    }

    /// Call when user stops viewing an asset in detail view
    func handleAssetViewEnded() {
        guard let result = assetViewTracker.end(),
              let asset = getAsset(at: result.index) else {
            return
        }

        analyticDelegate?.viewModel(
            self,
            didEndViewingAsset: asset,
            at: asset.position,
            viewDurationMs: result.viewDurationMs,
            netoWatchTimeMs: result.netoWatchTimeMs
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
