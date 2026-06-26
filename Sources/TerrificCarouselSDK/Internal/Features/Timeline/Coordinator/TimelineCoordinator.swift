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
        static let feedItemsPerPage = 10
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
    let likeStorage: LikeStorage?
    let analyticsService: AnalyticsService?
    private let errorLoggingService: ErrorLoggingService?
    let carouselId: String
    let storeId: String

    // MARK: - Public Event Handler
    /// Callback for SDK users to observe analytics events
    let onAnalyticsEvent: ((CarouselAnalyticsEvent) -> Void)?

    /// Shared poll state between Feed and Detail views
    let pollViewModelStore: PollViewModelStore

    // MARK: - ViewModels (Lazy Created)
    private(set) var _feedViewModel: TimelineViewModel?

    // MARK: - Init
    init(
        feedService: TimelineService,
        detailService: TimelineService,
        pollService: PollService? = nil,
        answerStorage: PollAnswerStorage? = nil,
        likeStorage: LikeStorage? = nil,
        analyticsService: AnalyticsService? = nil,
        errorLoggingService: ErrorLoggingService? = nil,
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
        self.errorLoggingService = errorLoggingService
        self.carouselId = carouselId
        self.storeId = storeId
        self.onAnalyticsEvent = onAnalyticsEvent
        self.pollViewModelStore = PollViewModelStore(
            pollService: pollService,
            answerStorage: answerStorage
        )
        self.pollViewModelStore.analyticDelegate = self
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
            pollViewModelStore: pollViewModelStore,
            errorLoggingService: errorLoggingService,
            errorRoute: .horizontalCarousel
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
            pollViewModelStore: pollViewModelStore,
            errorLoggingService: errorLoggingService,
            errorRoute: .verticalCarousel
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
