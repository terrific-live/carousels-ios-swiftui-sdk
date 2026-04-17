//
//  TimelineCoordinator.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 25.02.2026.
//

import SwiftUI
import Combine
import Pagination

// MARK: - TimelineCoordinator
/// Coordinates Timeline feature navigation and dependency management.
/// Owns shared state (PollViewModelStore) and creates ViewModels with proper dependencies.
@MainActor
final class TimelineCoordinator: ObservableObject {

    // MARK: - Configuration
    private enum Config {
        static let feedItemsPerPage = 20
        static let detailItemsPerPage = 10 // backend returns 20 items on 1 request no matter what you set, than 10 items per page
    }

    // MARK: - Navigation State
    @Published var isDetailPresented: Bool = false
    @Published private(set) var selectedAssetOffset: Int = 0
    private var selectedAssetId: String?

    // MARK: - Dependencies (Owned)
    private let feedService: TimelineService
    private let detailService: TimelineService
    private let pollService: PollService?
    private let answerStorage: PollAnswerStorage?
    private let likeStorage: LikeStorage?
    private let analyticsService: AnalyticsService?
    private let carouselId: String
    private let storeId: String

    // MARK: - Public Event Handler
    /// Callback for SDK users to observe analytics events
    private let onAnalyticsEvent: ((CarouselAnalyticsEvent) -> Void)?

    /// Shared poll state between Feed and Detail views
    let pollViewModelStore: PollViewModelStore

    // MARK: - ViewModels (Lazy Created)
    private var _feedViewModel: TimelineViewModel?

    // MARK: - Init
    init(
        feedService: TimelineService,
        detailService: TimelineService,
        pollService: PollService? = nil,
        answerStorage: PollAnswerStorage? = nil,
        likeStorage: LikeStorage? = nil,
        analyticsService: AnalyticsService? = nil,
        carouselId: String = "default",
        storeId: String = "",
        onAnalyticsEvent: ((CarouselAnalyticsEvent) -> Void)? = nil
    ) {
        self.feedService = feedService
        self.detailService = detailService
        self.pollService = pollService
        self.answerStorage = answerStorage
        self.likeStorage = likeStorage
        self.analyticsService = analyticsService
        self.carouselId = carouselId
        self.storeId = storeId
        self.onAnalyticsEvent = onAnalyticsEvent
        self.pollViewModelStore = PollViewModelStore(
            pollService: pollService,
            answerStorage: answerStorage
        )
        self.pollViewModelStore.analyticDelegate = self
    }

    private func findAsset(by assetId: String) -> TimelineAssetDTO? {
        // Search in feed view model
        for item in _feedViewModel?.carouselItems ?? [] {
            if case .content(let asset, _) = item, asset.id == assetId {
                return asset
            }
        }
        return nil
    }

    /// Convenience initializer with single service (for backwards compatibility)
    convenience init(timelineService: TimelineService, carouselId: String = "default") {
        self.init(
            feedService: timelineService,
            detailService: timelineService,
            pollService: nil,
            answerStorage: nil,
            analyticsService: nil,
            carouselId: carouselId
        )
    }

    // MARK: - ViewModel Factory Methods

    /// Returns the Feed ViewModel (creates lazily, reuses on subsequent calls)
    var feedViewModel: TimelineViewModel {
        if let existing = _feedViewModel {
            return existing
        }
        let pagination = Paginator<TimelineAssetDTO>(itemsPerPage: Config.feedItemsPerPage)
        pagination.paginationEnabled = false // Disable pagination for horizontal feed
        let viewModel = TimelineViewModel(
            timelineService: feedService,
            pagination: pagination,
            carouselId: carouselId,
            initialOffset: 0,
            pollViewModelStore: pollViewModelStore
        )
        viewModel.analyticDelegate = self
        viewModel.likeStateProvider = { [weak self] assetId in
            self?.isAssetLiked(assetId) ?? false
        }
        _feedViewModel = viewModel
        return viewModel
    }

    /// Creates a new Detail ViewModel with the current offset and start asset ID
    func makeDetailViewModel() -> TimelineViewModel {
        let pagination = Paginator<TimelineAssetDTO>(itemsPerPage: Config.detailItemsPerPage)
        let viewModel = TimelineViewModel(
            timelineService: detailService,
            pagination: pagination,
            carouselId: carouselId,
            initialOffset: selectedAssetOffset,
            startAssetId: selectedAssetId,
            pollViewModelStore: pollViewModelStore
        )
        viewModel.analyticDelegate = self
        viewModel.likeStateProvider = { [weak self] assetId in
            self?.isAssetLiked(assetId) ?? false
        }
        return viewModel
    }

    // MARK: - Navigation Actions

    /// Presents the Detail view starting at the specified asset offset
    func presentDetail(at offset: Int) {
        // Track carousel clicked before presenting
        trackCarouselClicked(at: offset)

        selectedAssetOffset = offset

        // Extract asset ID from feed view model
        let carouselItems = feedViewModel.carouselItems
        if offset < carouselItems.count,
           case .content(let asset, _) = carouselItems[offset] {
            selectedAssetId = asset.id
        } else {
            selectedAssetId = nil
        }

        isDetailPresented = true
    }

    /// Dismisses the Detail view
    func dismissDetail() {
        isDetailPresented = false
    }

    // MARK: - Like State

    /// Checks if an asset is liked
    func isAssetLiked(_ assetId: String) -> Bool {
        likeStorage?.isLiked(assetId) ?? false
    }
}

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
        viewDurationMs: Int
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
                externalUserId: nil
            )
        }
    }

    func viewModel(
        _ viewModel: TimelineViewModel,
        didCloseDetailWithParentUrl parentUrl: String,
        openDurationMs: Int
    ) {
        emit(.timelineClosed(parentUrl: parentUrl, durationMs: openDurationMs))

        sendAnalyticsIfEnabled("TimelineClosed") { [analyticsService, carouselId] in
            try await analyticsService?.trackTimelineClosed(
                carouselId: carouselId,
                parentUrl: parentUrl,
                openDurationMs: openDurationMs,
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

// MARK: - Private Helpers
private extension TimelineCoordinator {

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
