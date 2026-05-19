//
//  MockTimelineViewModelAnalyticDelegate.swift
//  TerrificCarouselSDKTests
//

import Foundation
@testable import TerrificCarouselSDK

@MainActor
final class MockTimelineViewModelAnalyticDelegate: TimelineViewModelAnalyticDelegate {

    // MARK: - Call Tracking
    private(set) var viewedAssets: [(asset: TimelineAssetDTO, position: Int, isInitialView: Bool)] = []
    private(set) var loadedAssets: [[TimelineAssetDTO]] = []
    private(set) var viewedCarouselAssets: [[TimelineAssetDTO]] = []
    private(set) var likedAssets: [TimelineAssetDTO] = []
    private(set) var detailOpenedParentUrls: [String] = []
    private(set) var detailClosedEvents: [(parentUrl: String, durationMs: Int)] = []
    private(set) var assetViewStartedEvents: [(asset: TimelineAssetDTO, position: Int)] = []
    private(set) var assetViewEndedEvents: [(asset: TimelineAssetDTO, position: Int, durationMs: Int)] = []
    private(set) var ctaClickedEvents: [(asset: TimelineAssetDTO, position: Int, url: String)] = []
    private(set) var shareEvents: [(asset: TimelineAssetDTO, position: Int)] = []
    private(set) var productClickEvents: [(product: ProductDTO, asset: TimelineAssetDTO, url: String)] = []

    // MARK: - TimelineViewModelAnalyticDelegate
    func viewModel(
        _ viewModel: TimelineViewModel,
        didViewAsset asset: TimelineAssetDTO,
        at position: Int,
        isInitialView: Bool
    ) {
        viewedAssets.append((asset, position, isInitialView))
    }

    func viewModel(
        _ viewModel: TimelineViewModel,
        didLoadAssets assets: [TimelineAssetDTO]
    ) {
        loadedAssets.append(assets)
    }

    func viewModel(
        _ viewModel: TimelineViewModel,
        didViewCarouselWithAssets assets: [TimelineAssetDTO]
    ) {
        viewedCarouselAssets.append(assets)
    }

    func viewModel(
        _ viewModel: TimelineViewModel,
        didLikeAsset asset: TimelineAssetDTO
    ) {
        likedAssets.append(asset)
    }

    func viewModel(
        _ viewModel: TimelineViewModel,
        didOpenDetailWithParentUrl parentUrl: String
    ) {
        detailOpenedParentUrls.append(parentUrl)
    }

    func viewModel(
        _ viewModel: TimelineViewModel,
        didStartViewingAsset asset: TimelineAssetDTO,
        at position: Int
    ) {
        assetViewStartedEvents.append((asset, position))
    }

    func viewModel(
        _ viewModel: TimelineViewModel,
        didEndViewingAsset asset: TimelineAssetDTO,
        at position: Int,
        viewDurationMs: Int
    ) {
        assetViewEndedEvents.append((asset, position, viewDurationMs))
    }

    func viewModel(
        _ viewModel: TimelineViewModel,
        didCloseDetailWithParentUrl parentUrl: String,
        openDurationMs: Int
    ) {
        detailClosedEvents.append((parentUrl, openDurationMs))
    }

    func viewModel(
        _ viewModel: TimelineViewModel,
        didClickCTAButton asset: TimelineAssetDTO,
        at position: Int,
        targetUrl: String
    ) {
        ctaClickedEvents.append((asset, position, targetUrl))
    }

    func viewModel(
        _ viewModel: TimelineViewModel,
        didShareAsset asset: TimelineAssetDTO,
        at position: Int
    ) {
        shareEvents.append((asset, position))
    }

    func viewModel(
        _ viewModel: TimelineViewModel,
        didClickProduct product: ProductDTO,
        inAsset asset: TimelineAssetDTO,
        targetUrl: String
    ) {
        productClickEvents.append((product, asset, targetUrl))
    }

    // MARK: - Reset
    func reset() {
        viewedAssets.removeAll()
        loadedAssets.removeAll()
        viewedCarouselAssets.removeAll()
        likedAssets.removeAll()
        detailOpenedParentUrls.removeAll()
        detailClosedEvents.removeAll()
        assetViewStartedEvents.removeAll()
        assetViewEndedEvents.removeAll()
        ctaClickedEvents.removeAll()
        shareEvents.removeAll()
        productClickEvents.removeAll()
    }
}
