//
//  TimelineCoordinatorTests.swift
//  TerrificCarouselSDKTests
//

import XCTest
@testable import TerrificCarouselSDK

@MainActor
final class TimelineCoordinatorTests: XCTestCase {

    // MARK: - Properties
    private var sut: TimelineCoordinator!
    private var mockFeedService: MockTimelineService!
    private var mockDetailService: MockTimelineService!
    private var mockPollService: MockPollService!
    private var mockAnswerStorage: MockPollAnswerStorage!
    private var mockLikeStorage: MockLikeStorage!
    private var mockAnalyticsService: MockAnalyticsService!
    private var mockErrorLoggingService: MockErrorLoggingService!
    private var capturedEvents: [CarouselAnalyticsEvent]!

    // MARK: - Setup & Teardown
    override func setUp() async throws {
        try await super.setUp()
        mockFeedService = MockTimelineService()
        mockDetailService = MockTimelineService()
        mockPollService = MockPollService()
        mockAnswerStorage = MockPollAnswerStorage()
        mockLikeStorage = MockLikeStorage()
        mockAnalyticsService = MockAnalyticsService()
        mockErrorLoggingService = MockErrorLoggingService()
        capturedEvents = []

        sut = TimelineCoordinator(
            feedService: mockFeedService,
            detailService: mockDetailService,
            pollService: mockPollService,
            answerStorage: mockAnswerStorage,
            likeStorage: mockLikeStorage,
            analyticsService: mockAnalyticsService,
            errorLoggingService: mockErrorLoggingService,
            carouselId: "test-carousel",
            storeId: "test-store",
            onAnalyticsEvent: { [weak self] event in
                self?.capturedEvents.append(event)
            }
        )
    }

    override func tearDown() async throws {
        sut = nil
        mockFeedService = nil
        mockDetailService = nil
        mockPollService = nil
        mockAnswerStorage = nil
        mockLikeStorage = nil
        mockAnalyticsService = nil
        mockErrorLoggingService = nil
        capturedEvents = nil
        try await super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState_isDetailPresentedIsFalse() {
        XCTAssertFalse(sut.isDetailPresented)
    }

    func testInitialState_selectedAssetOffsetIsZero() {
        XCTAssertEqual(sut.selectedAssetOffset, 0)
    }

    // MARK: - FeedViewModel Tests

    func testFeedViewModel_createsLazily() {
        // When
        let viewModel = sut.feedViewModel

        // Then
        XCTAssertNotNil(viewModel)
    }

    func testFeedViewModel_returnsSameInstanceOnSubsequentAccess() {
        // When
        let first = sut.feedViewModel
        let second = sut.feedViewModel

        // Then
        XCTAssertTrue(first === second)
    }

    func testFeedViewModel_hasAnalyticDelegateSet() {
        // When
        let viewModel = sut.feedViewModel

        // Then - the coordinator should be the delegate
        XCTAssertNotNil(viewModel.analyticDelegate)
    }

    // MARK: - MakeDetailViewModel Tests

    func testMakeDetailViewModel_createsNewInstance() {
        // When
        let first = sut.makeDetailViewModel()
        let second = sut.makeDetailViewModel()

        // Then - each call creates new instance
        XCTAssertFalse(first === second)
    }

    func testMakeDetailViewModel_hasAnalyticDelegateSet() {
        // When
        let viewModel = sut.makeDetailViewModel()

        // Then
        XCTAssertNotNil(viewModel.analyticDelegate)
    }

    // MARK: - Navigation Tests

    func testPresentDetail_setsIsDetailPresentedToTrue() {
        // Given - load some assets first
        mockFeedService.stubbedResult = TimelineServiceResult(
            assets: [TimelineAssetDTO.sample(id: "1")],
            carouselConfig: nil,
            anchor: nil
        )
        _ = sut.feedViewModel

        // When
        sut.presentDetail(at: 0)

        // Then
        XCTAssertTrue(sut.isDetailPresented)
    }

    func testPresentDetail_updatesSelectedAssetOffset() {
        // Given
        mockFeedService.stubbedResult = TimelineServiceResult(
            assets: [
                TimelineAssetDTO.sample(id: "1"),
                TimelineAssetDTO.sample(id: "2"),
                TimelineAssetDTO.sample(id: "3")
            ],
            carouselConfig: nil,
            anchor: nil
        )
        _ = sut.feedViewModel

        // When
        sut.presentDetail(at: 2)

        // Then
        XCTAssertEqual(sut.selectedAssetOffset, 2)
    }

    func testDismissDetail_setsIsDetailPresentedToFalse() {
        // Given
        sut.presentDetail(at: 0)
        XCTAssertTrue(sut.isDetailPresented)

        // When
        sut.dismissDetail()

        // Then
        XCTAssertFalse(sut.isDetailPresented)
    }

    // MARK: - Like State Tests

    func testIsAssetLiked_delegatesToLikeStorage() {
        // Given
        mockLikeStorage.setLiked("asset-1", isLiked: true)

        // When/Then
        XCTAssertTrue(sut.isAssetLiked("asset-1"))
        XCTAssertFalse(sut.isAssetLiked("asset-2"))
    }

    func testIsAssetLiked_withNilStorage_returnsFalse() {
        // Given - coordinator without like storage
        let coordinatorWithoutStorage = TimelineCoordinator(
            feedService: mockFeedService,
            detailService: mockDetailService,
            likeStorage: nil,
            carouselId: "test"
        )

        // When/Then
        XCTAssertFalse(coordinatorWithoutStorage.isAssetLiked("any-asset"))
    }

    // MARK: - TimelineViewModelAnalyticDelegate Tests

    func testDidViewAsset_emitsAssetViewedEvent() {
        // Given
        let asset = TimelineAssetDTO.sample(id: "asset-1")
        let viewModel = sut.feedViewModel

        // When
        sut.viewModel(viewModel, didViewAsset: asset, at: 0, isInitialView: true)

        // Then
        XCTAssertEqual(capturedEvents.count, 1)
        if case .assetViewed(let eventAsset, let position, let isInitial) = capturedEvents.first {
            XCTAssertEqual(eventAsset.id, "asset-1")
            XCTAssertEqual(position, 0)
            XCTAssertTrue(isInitial)
        } else {
            XCTFail("Expected assetViewed event")
        }
    }

    func testDidLoadAssets_emitsCarouselLoadedEvent_onlyForFeedViewModel() {
        // Given
        let assets = [TimelineAssetDTO.sample(id: "1"), TimelineAssetDTO.sample(id: "2")]
        let feedViewModel = sut.feedViewModel

        // When - notify from feed view model
        sut.viewModel(feedViewModel, didLoadAssets: assets)

        // Then
        XCTAssertEqual(capturedEvents.count, 1)
        if case .carouselLoaded(let eventAssets) = capturedEvents.first {
            XCTAssertEqual(eventAssets.count, 2)
        } else {
            XCTFail("Expected carouselLoaded event")
        }
    }

    func testDidLoadAssets_doesNotEmit_forDetailViewModel() {
        // Given
        let assets = [TimelineAssetDTO.sample(id: "1")]
        let detailViewModel = sut.makeDetailViewModel()

        // When - notify from detail view model
        sut.viewModel(detailViewModel, didLoadAssets: assets)

        // Then - no event emitted
        XCTAssertTrue(capturedEvents.isEmpty)
    }

    func testDidViewCarousel_emitsCarouselViewedEvent() {
        // Given
        let assets = [TimelineAssetDTO.sample(id: "1")]
        let viewModel = sut.feedViewModel

        // When
        sut.viewModel(viewModel, didViewCarouselWithAssets: assets)

        // Then
        XCTAssertEqual(capturedEvents.count, 1)
        if case .carouselViewed = capturedEvents.first {
            // Success
        } else {
            XCTFail("Expected carouselViewed event")
        }
    }

    func testDidLikeAsset_togglesLikeState() {
        // Given
        let asset = TimelineAssetDTO.sample(id: "asset-1")
        let viewModel = sut.feedViewModel
        XCTAssertFalse(mockLikeStorage.isLiked("asset-1"))

        // When - first like
        sut.viewModel(viewModel, didLikeAsset: asset)

        // Then - now liked
        XCTAssertTrue(mockLikeStorage.isLiked("asset-1"))

        // When - second like (unlike)
        sut.viewModel(viewModel, didLikeAsset: asset)

        // Then - now unliked
        XCTAssertFalse(mockLikeStorage.isLiked("asset-1"))
    }

    func testDidLikeAsset_emitsEvent_onlyWhenLiking() {
        // Given
        let asset = TimelineAssetDTO.sample(id: "asset-1")
        let viewModel = sut.feedViewModel

        // When - first like
        sut.viewModel(viewModel, didLikeAsset: asset)

        // Then - event emitted
        XCTAssertEqual(capturedEvents.count, 1)
        if case .assetLiked = capturedEvents.first {
            // Success
        } else {
            XCTFail("Expected assetLiked event")
        }

        // When - unlike (second call)
        sut.viewModel(viewModel, didLikeAsset: asset)

        // Then - no new event (still 1)
        XCTAssertEqual(capturedEvents.count, 1)
    }

    func testDidOpenDetail_emitsTimelineOpenedEvent() {
        // Given
        let viewModel = sut.feedViewModel

        // When
        sut.viewModel(viewModel, didOpenDetailWithParentUrl: "https://example.com")

        // Then
        XCTAssertEqual(capturedEvents.count, 1)
        if case .timelineOpened(let parentUrl) = capturedEvents.first {
            XCTAssertEqual(parentUrl, "https://example.com")
        } else {
            XCTFail("Expected timelineOpened event")
        }
    }

    func testDidStartViewingAsset_emitsAssetViewStartedEvent() {
        // Given
        let asset = TimelineAssetDTO.sample(id: "asset-1")
        let viewModel = sut.feedViewModel

        // When
        sut.viewModel(viewModel, didStartViewingAsset: asset, at: 5)

        // Then
        XCTAssertEqual(capturedEvents.count, 1)
        if case .assetViewStarted(let eventAsset, let position) = capturedEvents.first {
            XCTAssertEqual(eventAsset.id, "asset-1")
            XCTAssertEqual(position, 5)
        } else {
            XCTFail("Expected assetViewStarted event")
        }
    }

    func testDidEndViewingAsset_emitsAssetViewEndedEvent() {
        // Given
        let asset = TimelineAssetDTO.sample(id: "asset-1")
        let viewModel = sut.feedViewModel

        // When
        sut.viewModel(viewModel, didEndViewingAsset: asset, at: 3, viewDurationMs: 5000)

        // Then
        XCTAssertEqual(capturedEvents.count, 1)
        if case .assetViewEnded(let eventAsset, let position, let durationMs) = capturedEvents.first {
            XCTAssertEqual(eventAsset.id, "asset-1")
            XCTAssertEqual(position, 3)
            XCTAssertEqual(durationMs, 5000)
        } else {
            XCTFail("Expected assetViewEnded event")
        }
    }

    func testDidCloseDetail_emitsTimelineClosedEvent() {
        // Given
        let viewModel = sut.feedViewModel

        // When
        sut.viewModel(viewModel, didCloseDetailWithParentUrl: "https://example.com", openDurationMs: 10000)

        // Then
        XCTAssertEqual(capturedEvents.count, 1)
        if case .timelineClosed(let parentUrl, let durationMs) = capturedEvents.first {
            XCTAssertEqual(parentUrl, "https://example.com")
            XCTAssertEqual(durationMs, 10000)
        } else {
            XCTFail("Expected timelineClosed event")
        }
    }

    func testDidShareAsset_emitsAssetSharedEvent() {
        // Given
        let asset = TimelineAssetDTO.sample(id: "asset-1")
        let viewModel = sut.feedViewModel

        // When
        sut.viewModel(viewModel, didShareAsset: asset, at: 2)

        // Then
        XCTAssertEqual(capturedEvents.count, 1)
        if case .assetShared(let eventAsset, let position) = capturedEvents.first {
            XCTAssertEqual(eventAsset.id, "asset-1")
            XCTAssertEqual(position, 2)
        } else {
            XCTFail("Expected assetShared event")
        }
    }

    func testDidClickCTAButton_emitsCTAButtonClickedEvent() {
        // Given
        let asset = TimelineAssetDTO.sample(id: "asset-1")
        let viewModel = sut.feedViewModel

        // When
        sut.viewModel(viewModel, didClickCTAButton: asset, at: 1, targetUrl: "https://example.com")

        // Then
        XCTAssertEqual(capturedEvents.count, 1)
        if case .ctaButtonClicked(let eventAsset, let position, let targetUrl) = capturedEvents.first {
            XCTAssertEqual(eventAsset.id, "asset-1")
            XCTAssertEqual(position, 1)
            XCTAssertEqual(targetUrl, "https://example.com")
        } else {
            XCTFail("Expected ctaButtonClicked event")
        }
    }

    func testDidClickProduct_emitsProductClickedEvent() {
        // Given
        let asset = TimelineAssetDTO.sample(id: "asset-1", position: 3)
        let product = ProductDTO.sampleFull
        let viewModel = sut.feedViewModel

        // When
        sut.viewModel(viewModel, didClickProduct: product, inAsset: asset, targetUrl: "https://example.com/product")

        // Then
        XCTAssertEqual(capturedEvents.count, 1)
        if case .productClicked(let eventAsset, let eventProduct, let position, let targetUrl) = capturedEvents.first {
            XCTAssertEqual(eventAsset.id, "asset-1")
            XCTAssertEqual(eventProduct.id, product.id)
            XCTAssertEqual(position, 3)
            XCTAssertEqual(targetUrl, "https://example.com/product")
        } else {
            XCTFail("Expected productClicked event")
        }
    }

    func testDidClickCarouselSponsorship_emitsCarouselSponsorshipClickedEvent() {
        // Given
        let viewModel = sut.feedViewModel

        // When
        sut.viewModel(viewModel, didClickCarouselSponsorship: .topLogo, sponsorshipUrl: "https://sponsor.com")

        // Then
        XCTAssertEqual(capturedEvents.count, 1)
        if case .carouselSponsorshipClicked(let placement, let url) = capturedEvents.first {
            XCTAssertEqual(placement, "TopLogo")
            XCTAssertEqual(url, "https://sponsor.com")
        } else {
            XCTFail("Expected carouselSponsorshipClicked event")
        }
    }

    func testDidClickCarouselSponsorship_withNilUrl_emitsEvent() {
        // Given
        let viewModel = sut.feedViewModel

        // When
        sut.viewModel(viewModel, didClickCarouselSponsorship: .sideLogo, sponsorshipUrl: nil)

        // Then
        XCTAssertEqual(capturedEvents.count, 1)
        if case .carouselSponsorshipClicked(let placement, let url) = capturedEvents.first {
            XCTAssertEqual(placement, "SideLogo")
            XCTAssertNil(url)
        } else {
            XCTFail("Expected carouselSponsorshipClicked event")
        }
    }

    func testDidClickAssetSponsorship_emitsAssetSponsorshipClickedEvent() {
        // Given
        let asset = TimelineAssetDTO.sample(id: "asset-1")
        let viewModel = sut.feedViewModel

        // When
        sut.viewModel(
            viewModel,
            didClickAssetSponsorship: asset,
            sponsorshipPlacement: .badgeLogo,
            sponsorshipPosition: .top,
            clickPosition: .top,
            sponsorshipUrl: "https://sponsor.com/badge"
        )

        // Then
        XCTAssertEqual(capturedEvents.count, 1)
        if case .assetSponsorshipClicked(let eventAsset, let placement, let position, let clickPos, let url) = capturedEvents.first {
            XCTAssertEqual(eventAsset.id, "asset-1")
            XCTAssertEqual(placement, "badgeLogo")
            XCTAssertEqual(position, "top")
            XCTAssertEqual(clickPos, "Top")
            XCTAssertEqual(url, "https://sponsor.com/badge")
        } else {
            XCTFail("Expected assetSponsorshipClicked event")
        }
    }

    func testDidClickAssetSponsorship_withNilPositions_emitsEvent() {
        // Given
        let asset = TimelineAssetDTO.sample(id: "asset-1")
        let viewModel = sut.feedViewModel

        // When
        sut.viewModel(
            viewModel,
            didClickAssetSponsorship: asset,
            sponsorshipPlacement: .bannerLogo,
            sponsorshipPosition: nil,
            clickPosition: nil,
            sponsorshipUrl: nil
        )

        // Then
        XCTAssertEqual(capturedEvents.count, 1)
        if case .assetSponsorshipClicked(_, let placement, let position, let clickPos, let url) = capturedEvents.first {
            XCTAssertEqual(placement, "bannerLogo")
            XCTAssertNil(position)
            XCTAssertNil(clickPos)
            XCTAssertNil(url)
        } else {
            XCTFail("Expected assetSponsorshipClicked event")
        }
    }

    func testPresentDetail_emitsCarouselClickedEvent() async throws {
        // Given - load assets into feed
        mockFeedService.stubbedResult = TimelineServiceResult(
            assets: [
                TimelineAssetDTO.sample(id: "asset-0", position: 0),
                TimelineAssetDTO.sample(id: "asset-1", position: 1)
            ],
            carouselConfig: nil,
            anchor: nil
        )
        sut.feedViewModel.loadFirstPage()
        try await Task.sleep(nanoseconds: 200_000_000)

        // Clear events from load
        capturedEvents = []

        // When
        sut.presentDetail(at: 0)

        // Then
        XCTAssertEqual(capturedEvents.count, 1)
        if case .carouselClicked(let eventAsset, let position) = capturedEvents.first {
            XCTAssertEqual(eventAsset.id, "asset-0")
            XCTAssertEqual(position, 0)
        } else {
            XCTFail("Expected carouselClicked event")
        }
    }

    // MARK: - PollViewModelStore Tests

    func testPollViewModelStore_isCreated() {
        XCTAssertNotNil(sut.pollViewModelStore)
    }

    func testPollViewModelStore_hasAnalyticDelegateSet() {
        // The coordinator sets itself as analyticDelegate on pollViewModelStore
        XCTAssertNotNil(sut.pollViewModelStore.analyticDelegate)
    }

    // MARK: - Convenience Init Tests

    func testConvenienceInit_usesSameServiceForBoth() {
        // Given/When
        let coordinator = TimelineCoordinator(
            timelineService: mockFeedService,
            carouselId: "test"
        )

        // Then - should not crash, basic functionality works
        XCTAssertFalse(coordinator.isDetailPresented)
        XCTAssertNotNil(coordinator.feedViewModel)
    }
}

// MARK: - PollViewModelAnalyticDelegate Tests
@MainActor
final class TimelineCoordinatorPollDelegateTests: XCTestCase {

    private var sut: TimelineCoordinator!
    private var mockFeedService: MockTimelineService!
    private var mockPollService: MockPollService!
    private var capturedEvents: [CarouselAnalyticsEvent]!

    override func setUp() async throws {
        try await super.setUp()
        mockFeedService = MockTimelineService()
        mockPollService = MockPollService()
        capturedEvents = []

        sut = TimelineCoordinator(
            feedService: mockFeedService,
            detailService: mockFeedService,
            pollService: mockPollService,
            carouselId: "test-carousel",
            onAnalyticsEvent: { [weak self] event in
                self?.capturedEvents.append(event)
            }
        )
    }

    override func tearDown() async throws {
        sut = nil
        mockFeedService = nil
        mockPollService = nil
        capturedEvents = nil
        try await super.tearDown()
    }

    func testPollVoted_doesNotEmit_whenAssetNotFound() {
        // Given - no assets loaded
        let pollViewModel = PollViewModel(
            assetId: "non-existent-asset",
            pollData: PollData.sample
        )

        // When
        sut.pollViewModel(
            pollViewModel,
            didVoteForAssetId: "non-existent-asset",
            pollId: "poll-123",
            pollAnswer: "Blue",
            questionId: "q-1"
        )

        // Then - no event emitted because asset wasn't found
        XCTAssertTrue(capturedEvents.isEmpty)
    }

    func testPollVoted_emitsEvent_whenAssetFound() async throws {
        // Given - load assets so findAsset can find them
        mockFeedService.stubbedResult = TimelineServiceResult(
            assets: [TimelineAssetDTO.sample(id: "poll-asset", position: 2)],
            carouselConfig: nil,
            anchor: nil
        )
        sut.feedViewModel.loadFirstPage()
        try await Task.sleep(nanoseconds: 200_000_000)

        // Clear events from load
        capturedEvents = []

        let pollViewModel = PollViewModel(
            assetId: "poll-asset",
            pollData: PollData.sample
        )

        // When
        sut.pollViewModel(
            pollViewModel,
            didVoteForAssetId: "poll-asset",
            pollId: "poll-123",
            pollAnswer: "Blue",
            questionId: "q-1"
        )

        // Then
        XCTAssertEqual(capturedEvents.count, 1)
        if case .pollVoted(let eventAsset, let position, let pollId, let answer) = capturedEvents.first {
            XCTAssertEqual(eventAsset.id, "poll-asset")
            XCTAssertEqual(position, 2)
            XCTAssertEqual(pollId, "poll-123")
            XCTAssertEqual(answer, "Blue")
        } else {
            XCTFail("Expected pollVoted event")
        }
    }
}
