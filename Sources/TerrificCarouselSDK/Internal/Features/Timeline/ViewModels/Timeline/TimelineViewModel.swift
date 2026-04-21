//
//  TimelineViewModel.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 14.01.2026.
//

import Foundation
import Combine
import Pagination
import ImageLoader
import UIKit

// MARK: - Types
extension TimelineViewModel {
    enum ViewState: Equatable {
        case idle
        case loading
        case content([TimelineAssetDTO])
        case error(String)
    }

    /// Type alias for carousel items with loading state
    typealias TimelineCarouselItem = CarouselItem<TimelineAssetDTO>
}

// MARK: - View Model
@MainActor
final class TimelineViewModel: ObservableObject {

    // MARK: - Published State (Interface)
    @Published
    var state: ViewState = .idle
    @Published
    var currentPageIndex: Int = 0
    @Published
    private(set) var carouselConfig: CarouselConfigDTO = .default

    // MARK: - Computed Properties
    /// Carousel items including loading placeholder when more pages exist.
    /// This makes skeleton a first-class item with a real index.
    var carouselItems: [TimelineCarouselItem] {
        guard case .content(let assets) = state else { return [] }
        return .carouselItems(from: assets, hasMorePages: pagination.hasMorePages)
    }

    // MARK: - Dependencies
    private let pagination: Paginator<TimelineAssetDTO>
    private let imagePrefetcher = SequentialImagePrefetcher()
    private let timelineService: TimelineService

    /// Shared store for poll view models - exposed for sharing between Feed and Detail
    let pollViewModelStore: PollViewModelStore

    // MARK: - Inputs
    private let carouselId: String
    private let initialOffset: Int
    private let startAssetId: String?

    // MARK: - Asset View Tracking
    /// Tracks which assets have been viewed to avoid duplicate events
    private var viewedAssetIds: Set<String> = []
    /// True until the user scrolls/changes page - used to determine isInitialView
    private(set) var isInitialCarouselState: Bool = true

    // MARK: - Auto-Advance State
    static let imageDisplayDuration: TimeInterval = 8
    private var autoAdvanceTask: Task<Void, Never>?
    /// autoAdvanceEnabled is the flag that also indicates we're in detail view
    private var autoAdvanceEnabled: Bool = false
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Asset View Duration Tracking
    /// Tracks the currently viewed asset index and start time for duration calculation
    private var currentViewStartTime: Date?
    private var currentViewAssetIndex: Int?

    // MARK: - Timeline Open Duration Tracking
    /// Tracks when the timeline detail view was opened
    private var timelineDetailsOpenedTime: Date?

    // MARK: - Cursor-Based Pagination
    /// Anchor for cursor-based pagination (used by detail view)
    private var currentAnchor: String?

    // MARK: - Analytic Delegate
    weak var analyticDelegate: TimelineViewModelAnalyticDelegate?

    // MARK: - Like State Provider
    /// Closure to check if an asset is liked. Set by coordinator.
    var likeStateProvider: ((String) -> Bool)?

    // MARK: - Init
    /// Creates a TimelineViewModel.
    /// - Parameters:
    ///   - timelineService: Service for fetching timeline assets
    ///   - pagination: Paginator for managing pagination state
    ///   - carouselId: Timeline identifier
    ///   - initialOffset: Starting offset in the timeline (default 0). Used by Detail to start at tapped item.
    ///   - startAssetId: Asset ID to start from (for detail view, sent only on first page)
    ///   - pollViewModelStore: Shared store for poll state. Pass from Feed to Detail for state sharing.
    init(
        timelineService: TimelineService,
        pagination: Paginator<TimelineAssetDTO>,
        carouselId: String = "default",
        initialOffset: Int = 0,
        startAssetId: String? = nil,
        pollViewModelStore: PollViewModelStore = PollViewModelStore()
    ) {
        self.timelineService = timelineService
        self.pagination = pagination
        self.carouselId = carouselId
        self.initialOffset = initialOffset
        self.startAssetId = startAssetId
        self.pollViewModelStore = pollViewModelStore

        bindAutoAdvance()
    }
}

// MARK: - View Data Factory
extension TimelineViewModel {

    /// Creates TimelineAssetViewData with persistent PollViewModel from the store.
    /// This ensures poll state is preserved during the carousel lifetime.
    func makeViewData(from asset: TimelineAssetDTO) -> TimelineAssetData {
        // Get or create PollViewModel from the store
        let pollData: PollData? = asset.pollData.map { PollData(from: $0) }
        let pollViewModel = pollViewModelStore.getOrCreate(for: asset.id, pollData: pollData)

        return TimelineAssetData(from: asset, pollViewModel: pollViewModel, carouselConfig: carouselConfig)
    }
}

// MARK: - Intents (Actions)
extension TimelineViewModel {

    func handleOnAppear() {
        guard case .idle = state else { return }
        loadFirstPage()
    }

    func loadFirstPage() {
        state = .loading
        pagination.reset()
        currentAnchor = nil  // Reset anchor for first page

        Task {
            await loadNextPage(isFirstPage: true)
        }
    }

    func handlePageChange(to index: Int) {
        // Mark that user has scrolled (no longer initial state)
        if isInitialCarouselState && index != 0 {
            isInitialCarouselState = false
        }

        // Handle prefetching (business logic) - only for content items
        if case .content(let assets) = state, index < assets.count {
            imagePrefetcher.onSelectionChanged(currentIndex: index, items: assets)
        }

        // Handle pagination when user reaches loading item or near end
        // Use assets count for pagination check, not carousel items count
        let assetsCount = pagination.items.count
        let isOnLoadingItem = index >= assetsCount
        let isNearEnd = pagination.shouldLoadNextPage(for: min(index, assetsCount - 1))

        /*
        When isOnLoadingItem is true, we trigger pagination because the user has reached the loading placeholder and is waiting for new content.
        The isNearEnd check handles the prefetch case (loading before user actually reaches the skeleton), while isOnLoadingItem handles the case where the user has already scrolled to the skeleton.
         */
        guard isOnLoadingItem || isNearEnd else { return }
        Task {
            await loadNextPage(isFirstPage: false)
        }
    }

    /// Call when an asset card appears on screen
    /// - Parameters:
    ///   - asset: The asset that appeared
    ///   - position: The asset's position in the carousel
    func handleAssetAppeared(_ asset: TimelineAssetDTO) {
        // Only track each asset once
        guard !viewedAssetIds.contains(asset.id) else { return }
        viewedAssetIds.insert(asset.id)

        // isInitialView is true only if user hasn't scrolled yet
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
        // Trigger UI update after like state changes
        objectWillChange.send()
    }

    /// Checks if an asset is liked
    func isAssetLiked(_ assetId: String) -> Bool {
        likeStateProvider?(assetId) ?? false
    }

    /// Call when timeline detail view appears on screen
    func handleDetailOpened() {
        // Track when detail view was opened
        timelineDetailsOpenedTime = Date()

        // Get parentUrl from current asset
        let parentUrl = getAsset(at: currentPageIndex)?.parentUrl ?? ""
        analyticDelegate?.viewModel(self, didOpenDetailWithParentUrl: parentUrl)
    }

    /// Call when timeline detail view is closed
    func handleDetailClosed() {
        guard let openedTime = timelineDetailsOpenedTime else { return }

        // Calculate open duration in milliseconds
        let openDurationMs = Int(Date().timeIntervalSince(openedTime) * 1000)

        // Get parentUrl from current asset
        let parentUrl = getAsset(at: currentPageIndex)?.parentUrl ?? ""

        // Reset tracking state
        timelineDetailsOpenedTime = nil

        analyticDelegate?.viewModel(self, didCloseDetailWithParentUrl: parentUrl, openDurationMs: openDurationMs)
    }

    /// Call when user starts viewing an asset in detail view
    func handleAssetViewStarted(at index: Int) {
        // End previous view if exists
        handleAssetViewEnded()

        guard let asset = getAsset(at: index) else { return }

        // Track start time for duration calculation
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

        // Calculate view duration in milliseconds
        let viewDurationMs = Int(Date().timeIntervalSince(startTime) * 1000)

        // Reset tracking state
        currentViewStartTime = nil
        currentViewAssetIndex = nil

        analyticDelegate?.viewModel(self, didEndViewingAsset: asset, at: asset.position, viewDurationMs: viewDurationMs)
    }

    // MARK: - Auto-Advance Logic

    /// Enables auto-advance and triggers it for current asset
    func enableAutoAdvance() {
        autoAdvanceEnabled = true
        handleCurrentAssetChanged()
    }

    /// Call when video playback finishes
    func handleVideoFinished() {
        guard autoAdvanceEnabled else { return }
        advanceToNextItem()
    }

    /// Handles detail view disappear - cancels auto-advance and tracks analytics
    func handleDetailViewDisappear() {
        // End current asset view before disabling
        handleAssetViewEnded()

        // Track timeline closed
        handleDetailClosed()

        autoAdvanceEnabled = false
        autoAdvanceTask?.cancel()
        autoAdvanceTask = nil
    }

    // MARK: - URL Actions

    /// Notifies delegate about CTA button tap (coordinator handles URL opening)
    func handleCtaButtonTap(asset: TimelineAssetDTO, url: URL?) {
        guard let url else { return }

        // Notify delegate - coordinator will track analytics and open URL
        analyticDelegate?.viewModel(
            self,
            didClickCTAButton: asset,
            at: asset.position,
            targetUrl: url.absoluteString
        )
    }

    /// Notifies delegate about product CTA tap (coordinator handles URL opening)
    /// - Parameters:
    ///   - product: The product that was clicked
    ///   - asset: The asset containing the product
    ///   - url: The URL to navigate to
    func handleProductCtaTap(product: ProductDTO, asset: TimelineAssetDTO, url: URL?) {
        guard let url else { return }

        // Notify delegate - coordinator will track analytics and open URL
        analyticDelegate?.viewModel(
            self,
            didClickProduct: product,
            inAsset: asset,
            targetUrl: url.absoluteString
        )
    }

    /// Tracks when user shares an asset
    func handleAssetShared(_ asset: TimelineAssetDTO) {
        analyticDelegate?.viewModel(self, didShareAsset: asset, at: asset.position)
    }
}

// MARK: - Internal Logic
private extension TimelineViewModel {

    func bindAutoAdvance() {
        // Observe page index changes
        // Note: @Published emits on willSet, so we must use the emitted value, not currentPageIndex
        $currentPageIndex
            .dropFirst() // Skip initial value
            .sink { [weak self] newIndex in
                self?.handleCurrentAssetChanged(at: newIndex)
            }
            .store(in: &cancellables)
    }

    func handleCurrentAssetChanged(at index: Int? = nil) {
        // Cancel any existing auto-advance task
        autoAdvanceTask?.cancel()
        autoAdvanceTask = nil

        guard autoAdvanceEnabled else { return }

        // Get current asset (use provided index or fall back to currentPageIndex)
        let targetIndex = index ?? currentPageIndex
        guard let currentAsset = getAsset(at: targetIndex) else { return }

        // Track asset view started
        handleAssetViewStarted(at: targetIndex)

        // For images and polls, start timer
        // For videos, wait for handleVideoFinished callback
        if currentAsset.type != .video {
            startAutoAdvanceTimer()
        }
    }

    func loadNextPage(isFirstPage: Bool) async {
        let previousCount = pagination.items.count

        do {
            try await pagination.loadNextPage { page, itemsPerPage in
                // Pass startAssetId only for first page request
                let startAssetIdForRequest = isFirstPage ? self.startAssetId : nil

                let result = try await self.timelineService.fetchAssets(
                    for: self.carouselId,
                    page: page,
                    itemsPerPage: itemsPerPage,
                    offset: self.initialOffset,
                    anchor: self.currentAnchor,
                    startAssetId: startAssetIdForRequest
                )

                // Store carouselConfig from first page response
                if isFirstPage, let config = result.carouselConfig {
                    await MainActor.run {
                        self.carouselConfig = config
                    }
                }

                // Store anchor for next page request
                await MainActor.run {
                    self.currentAnchor = result.anchor
                }

                return result.assets
            }

            // Force state update to trigger view re-render
            // This ensures carouselItems recomputes with latest hasMorePages value
            state = .content(pagination.items)

            // If user was on the loading skeleton and there are no more pages,
            // adjust currentPageIndex to the last valid content item
            let maxValidIndex = pagination.items.count - 1
            if !pagination.hasMorePages && currentPageIndex > maxValidIndex {
                currentPageIndex = max(0, maxValidIndex)
            }

            // Trigger auto-advance and detail opened event for first page if enabled
            if isFirstPage && autoAdvanceEnabled {
                handleCurrentAssetChanged()
                handleDetailOpened()
            }

            // Notify about newly loaded assets
            let newAssets = Array(pagination.items.dropFirst(previousCount))
            if !newAssets.isEmpty {
                analyticDelegate?.viewModel(self, didLoadAssets: newAssets)
            }

        } catch {
            if isFirstPage {
                state = .error(error.localizedDescription)
            }
        }
    }

    // MARK: - Auto-Advance Helpers

    func startAutoAdvanceTimer() {
        autoAdvanceTask = Task {
            do {
                try await Task.sleep(nanoseconds: UInt64(Self.imageDisplayDuration * 1_000_000_000))
                if !Task.isCancelled {
                    advanceToNextItem()
                }
            } catch {
                // Task was cancelled, do nothing
            }
        }
    }

    func advanceToNextItem() {
        let nextIndex = currentPageIndex + 1
        let itemCount = carouselItems.count

        // Only advance if there's a next item
        guard nextIndex < itemCount else { return }

        currentPageIndex = nextIndex
    }

    func getAsset(at index: Int) -> TimelineAssetDTO? {
        let items = carouselItems

        guard index < items.count else { return nil }

        if case .content(let asset, _) = items[index] {
            return asset
        }
        return nil
    }
}
