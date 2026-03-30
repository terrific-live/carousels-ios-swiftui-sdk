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
        static let detailItemsPerPage = 20 // backend returns 20 no matter what you request
    }

    // MARK: - Navigation State
    @Published var isDetailPresented: Bool = false
    @Published private(set) var selectedAssetOffset: Int = 0

    // MARK: - Dependencies (Owned)
    private let feedService: TimelineService
    private let detailService: TimelineService
    private let pollService: PollService?
    private let answerStorage: PollAnswerStorage?
    private let likeStorage: LikeStorage?
    private let analyticsService: AnalyticsService?
    private let carouselId: String

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
        onAnalyticsEvent: ((CarouselAnalyticsEvent) -> Void)? = nil
    ) {
        self.feedService = feedService
        self.detailService = detailService
        self.pollService = pollService
        self.answerStorage = answerStorage
        self.likeStorage = likeStorage
        self.analyticsService = analyticsService
        self.carouselId = carouselId
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

    /// Creates a new Detail ViewModel with the current offset
    func makeDetailViewModel() -> TimelineViewModel {
        let pagination = Paginator<TimelineAssetDTO>(itemsPerPage: Config.detailItemsPerPage)
        let viewModel = TimelineViewModel(
            timelineService: detailService,
            pagination: pagination,
            carouselId: carouselId,
            initialOffset: selectedAssetOffset,
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

        Task {
            do {
                try await analyticsService?.trackAssetViewed(
                    carouselId: carouselId,
                    asset: asset,
                    position: position,
                    isInitialView: isInitialView,
                    externalUserId: nil
                )
                AnalyticsLogger.success("AssetViewed")
            } catch {
                AnalyticsLogger.error("AssetViewed", errorMessage: "\(error.localizedDescription)")
            }
        }
    }

    func viewModel(
        _ viewModel: TimelineViewModel,
        didLoadAssets assets: [TimelineAssetDTO]
    ) {
        // Only track CarouselLoaded for feed, not detail
        guard viewModel === _feedViewModel else { return }

        emit(.carouselLoaded(assets: assets.map { CarouselAsset(from: $0) }))

        Task {
            do {
                try await analyticsService?.trackCarouselLoaded(
                    carouselId: carouselId,
                    assets: assets,
                    externalUserId: nil
                )
                AnalyticsLogger.success("CarouselLoaded")
            } catch {
                AnalyticsLogger.error("CarouselLoaded", errorMessage: "\(error.localizedDescription)")
            }
        }
    }

    func viewModel(
        _ viewModel: TimelineViewModel,
        didViewCarouselWithAssets assets: [TimelineAssetDTO]
    ) {
        emit(.carouselViewed(assets: assets.map { CarouselAsset(from: $0) }))

        Task {
            do {
                try await analyticsService?.trackCarouselViewed(
                    carouselId: carouselId,
                    assets: assets,
                    externalUserId: nil
                )
                AnalyticsLogger.success("CarouselViewed")
            } catch {
                AnalyticsLogger.error("CarouselViewed", errorMessage: "\(error.localizedDescription)")
            }
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

        Task {
            do {
                try await analyticsService?.trackAssetLiked(
                    carouselId: carouselId,
                    asset: asset,
                    externalUserId: nil
                )
                AnalyticsLogger.success("AssetLiked")
            } catch {
                AnalyticsLogger.error("AssetLiked", errorMessage: "\(error.localizedDescription)")
            }
        }
    }

    func viewModel(
        _ viewModel: TimelineViewModel,
        didOpenDetailWithParentUrl parentUrl: String
    ) {
        emit(.timelineOpened(parentUrl: parentUrl))

        Task {
            do {
                try await analyticsService?.trackTimelineOpened(
                    carouselId: carouselId,
                    parentUrl: parentUrl,
                    externalUserId: nil
                )
                AnalyticsLogger.success("TimelineOpened")
            } catch {
                AnalyticsLogger.error("TimelineOpened", errorMessage: "\(error.localizedDescription)")
            }
        }
    }

    func viewModel(
        _ viewModel: TimelineViewModel,
        didStartViewingAsset asset: TimelineAssetDTO,
        at position: Int
    ) {
        emit(.assetViewStarted(asset: CarouselAsset(from: asset), position: position))

        Task {
            do {
                try await analyticsService?.trackAssetViewStarted(
                    carouselId: carouselId,
                    asset: asset,
                    position: position,
                    externalUserId: nil
                )
                AnalyticsLogger.success("AssetViewStarted")
            } catch {
                AnalyticsLogger.error("AssetViewStarted", errorMessage: "\(error.localizedDescription)")
            }
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

        Task {
            do {
                try await analyticsService?.trackAssetViewEnded(
                    carouselId: carouselId,
                    asset: asset,
                    position: position,
                    viewDurationMs: viewDurationMs,
                    externalUserId: nil
                )
                AnalyticsLogger.success("AssetViewEnded")
            } catch {
                AnalyticsLogger.error("AssetViewEnded", errorMessage: "\(error.localizedDescription)")
            }
        }
    }

    func viewModel(
        _ viewModel: TimelineViewModel,
        didCloseDetailWithParentUrl parentUrl: String,
        openDurationMs: Int
    ) {
        emit(.timelineClosed(parentUrl: parentUrl, durationMs: openDurationMs))

        Task {
            do {
                try await analyticsService?.trackTimelineClosed(
                    carouselId: carouselId,
                    parentUrl: parentUrl,
                    openDurationMs: openDurationMs,
                    externalUserId: nil
                )
                AnalyticsLogger.success("TimelineClosed")
            } catch {
                AnalyticsLogger.error("TimelineClosed", errorMessage: "\(error.localizedDescription)")
            }
        }
    }

    func viewModel(
        _ viewModel: TimelineViewModel,
        didClickCTAButton asset: TimelineAssetDTO,
        at position: Int,
        targetUrl: String
    ) {
        emit(.ctaButtonClicked(
            asset: CarouselAsset(from: asset),
            position: position,
            targetUrl: targetUrl
        ))

        Task {
            do {
                try await analyticsService?.trackCTAButtonClicked(
                    carouselId: carouselId,
                    asset: asset,
                    position: position,
                    targetUrl: targetUrl,
                    externalUserId: nil
                )
                AnalyticsLogger.success("CTAButtonClicked")
            } catch {
                AnalyticsLogger.error("CTAButtonClicked", errorMessage: "\(error.localizedDescription)")
            }
        }
    }

    func viewModel(
        _ viewModel: TimelineViewModel,
        didShareAsset asset: TimelineAssetDTO,
        at position: Int
    ) {
        emit(.assetShared(asset: CarouselAsset(from: asset), position: position))

        Task {
            do {
                try await analyticsService?.trackAssetShared(
                    carouselId: carouselId,
                    asset: asset,
                    position: position,
                    externalUserId: nil
                )
                AnalyticsLogger.success("AssetShared")
            } catch {
                AnalyticsLogger.error("AssetShared", errorMessage: "\(error.localizedDescription)")
            }
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

        Task {
            do {
                try await analyticsService?.trackPollVoted(
                    carouselId: carouselId,
                    asset: asset,
                    position: asset.position,
                    pollId: pollId,
                    pollAnswer: pollAnswer,
                    questionId: questionId,
                    externalUserId: nil
                )
                AnalyticsLogger.success("PollVoted")
            } catch {
                AnalyticsLogger.error("PollVoted", errorMessage: "\(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Private Helpers
private extension TimelineCoordinator {

    /// Emits an analytics event to SDK users
    func emit(_ event: CarouselAnalyticsEvent) {
        onAnalyticsEvent?(event)
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

        Task {
            do {
                try await analyticsService?.trackCarouselClicked(
                    carouselId: carouselId,
                    clickedAsset: clickedAsset,
                    allAssets: assets,
                    position: clickedAsset.position,
                    externalUserId: nil
                )
                AnalyticsLogger.success("CarouselClicked")
            } catch {
                AnalyticsLogger.error("CarouselClicked", errorMessage: "\(error.localizedDescription)")
            }
        }
    }
}
