//
//  TimelineViewModelAnalyticDelegate.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 20.03.2026.
//

import Foundation

// MARK: - Analytic Delegate Protocol
@MainActor
protocol TimelineViewModelAnalyticDelegate: AnyObject {
    /// Called when an asset appears on screen for the first time
    func viewModel(
        _ viewModel: TimelineViewModel,
        didViewAsset asset: TimelineAssetDTO,
        at position: Int,
        isInitialView: Bool
    )

    /// Called when a new page of assets is loaded
    func viewModel(
        _ viewModel: TimelineViewModel,
        didLoadAssets assets: [TimelineAssetDTO]
    )

    /// Called when the carousel view appears on screen
    func viewModel(
        _ viewModel: TimelineViewModel,
        didViewCarouselWithAssets assets: [TimelineAssetDTO]
    )

    /// Called when user likes an asset
    func viewModel(
        _ viewModel: TimelineViewModel,
        didLikeAsset asset: TimelineAssetDTO
    )

    /// Called when timeline detail view appears on screen
    func viewModel(
        _ viewModel: TimelineViewModel,
        didOpenDetailWithParentUrl parentUrl: String
    )

    /// Called when user starts viewing an asset in detail view
    func viewModel(
        _ viewModel: TimelineViewModel,
        didStartViewingAsset asset: TimelineAssetDTO,
        at position: Int
    )

    /// Called when user stops viewing an asset in detail view
    func viewModel(
        _ viewModel: TimelineViewModel,
        didEndViewingAsset asset: TimelineAssetDTO,
        at position: Int,
        viewDurationMs: Int
    )

    /// Called when timeline detail view is closed
    func viewModel(
        _ viewModel: TimelineViewModel,
        didCloseDetailWithParentUrl parentUrl: String,
        openDurationMs: Int
    )

    /// Called when user clicks a CTA button
    func viewModel(
        _ viewModel: TimelineViewModel,
        didClickCTAButton asset: TimelineAssetDTO,
        at position: Int,
        targetUrl: String
    )

    /// Called when user shares an asset
    func viewModel(
        _ viewModel: TimelineViewModel,
        didShareAsset asset: TimelineAssetDTO,
        at position: Int
    )
}

// MARK: - Default implementations (optional methods)
extension TimelineViewModelAnalyticDelegate {
    func viewModel(_ viewModel: TimelineViewModel, didViewAsset asset: TimelineAssetDTO, at position: Int, isInitialView: Bool) {}
    func viewModel(_ viewModel: TimelineViewModel, didLoadAssets assets: [TimelineAssetDTO]) {}
    func viewModel(_ viewModel: TimelineViewModel, didViewCarouselWithAssets assets: [TimelineAssetDTO]) {}
    func viewModel(_ viewModel: TimelineViewModel, didLikeAsset asset: TimelineAssetDTO) {}
    func viewModel(_ viewModel: TimelineViewModel, didOpenDetailWithParentUrl parentUrl: String) {}
    func viewModel(_ viewModel: TimelineViewModel, didStartViewingAsset asset: TimelineAssetDTO, at position: Int) {}
    func viewModel(_ viewModel: TimelineViewModel, didEndViewingAsset asset: TimelineAssetDTO, at position: Int, viewDurationMs: Int) {}
    func viewModel(_ viewModel: TimelineViewModel, didCloseDetailWithParentUrl parentUrl: String, openDurationMs: Int) {}
    func viewModel(_ viewModel: TimelineViewModel, didClickCTAButton asset: TimelineAssetDTO, at position: Int, targetUrl: String) {}
    func viewModel(_ viewModel: TimelineViewModel, didShareAsset asset: TimelineAssetDTO, at position: Int) {}
}
