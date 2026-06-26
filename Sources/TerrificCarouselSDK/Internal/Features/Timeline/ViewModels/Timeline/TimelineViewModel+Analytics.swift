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
        timelineDetailsOpenedTime = Date()
        let parentUrl = getAsset(at: currentPageIndex)?.parentUrl ?? ""
        analyticDelegate?.viewModel(self, didOpenDetailWithParentUrl: parentUrl)
    }

    /// Call when timeline detail view is closed
    func handleDetailClosed() {
        guard let openedTime = timelineDetailsOpenedTime else { return }

        let openDurationMs = Int(Date().timeIntervalSince(openedTime) * 1000)
        let parentUrl = getAsset(at: currentPageIndex)?.parentUrl ?? ""

        timelineDetailsOpenedTime = nil

        analyticDelegate?.viewModel(self, didCloseDetailWithParentUrl: parentUrl, openDurationMs: openDurationMs)
    }

    /// Call when user starts viewing an asset in detail view
    func handleAssetViewStarted(at index: Int) {
        handleAssetViewEnded()

        guard let asset = getAsset(at: index) else { return }

        currentViewStartTime = Date()
        currentViewAssetIndex = index

        analyticDelegate?.viewModel(self, didStartViewingAsset: asset, at: asset.position)
    }

    /// Call when user stops viewing an asset in detail view
    func handleAssetViewEnded() {
        guard let startTime = currentViewStartTime,
              let assetIndex = currentViewAssetIndex,
              let asset = getAsset(at: assetIndex) else {
            return
        }

        let viewDurationMs = Int(Date().timeIntervalSince(startTime) * 1000)

        currentViewStartTime = nil
        currentViewAssetIndex = nil

        analyticDelegate?.viewModel(self, didEndViewingAsset: asset, at: asset.position, viewDurationMs: viewDurationMs)
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
