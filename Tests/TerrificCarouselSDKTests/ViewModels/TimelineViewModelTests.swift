//
//  TimelineViewModelTests.swift
//  TerrificCarouselSDKTests
//

import XCTest
import Pagination
@testable import TerrificCarouselSDK

@MainActor
final class TimelineViewModelTests: XCTestCase {

    // MARK: - Properties
    private var sut: TimelineViewModel!
    private var mockService: MockTimelineService!
    private var mockAnalyticDelegate: MockTimelineViewModelAnalyticDelegate!
    private var mockErrorLoggingService: MockErrorLoggingService!
    private var paginator: Paginator<TimelineAssetDTO>!

    // MARK: - Setup & Teardown
    override func setUp() async throws {
        try await super.setUp()
        mockService = MockTimelineService()
        mockAnalyticDelegate = MockTimelineViewModelAnalyticDelegate()
        mockErrorLoggingService = MockErrorLoggingService()
        paginator = Paginator(itemsPerPage: 10, prefetchOffset: 2)

        sut = TimelineViewModel(
            timelineService: mockService,
            pagination: paginator,
            carouselId: "test-carousel",
            errorLoggingService: mockErrorLoggingService
        )
        sut.analyticDelegate = mockAnalyticDelegate
    }

    override func tearDown() async throws {
        sut = nil
        mockService = nil
        mockAnalyticDelegate = nil
        mockErrorLoggingService = nil
        paginator = nil
        try await super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState_isIdle() {
        XCTAssertEqual(sut.state, .idle)
        XCTAssertEqual(sut.currentPageIndex, 0)
        XCTAssertTrue(sut.carouselItems.isEmpty)
    }

    // MARK: - Load First Page Tests

    func testHandleOnAppear_whenIdle_loadsFirstPage() async throws {
        // Given
        let assets: [TimelineAssetDTO] = .samplePage(count: 5)
        mockService.stubbedResult = .sample(assets: assets)

        // When
        sut.handleOnAppear()

        // Wait for async loading
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(sut.state, .content(assets))
        XCTAssertEqual(mockService.fetchAssetsCallCount, 1)
        XCTAssertEqual(mockService.lastFetchCarouselId, "test-carousel")
    }

    func testHandleOnAppear_whenNotIdle_doesNotReload() async throws {
        // Given - already loading
        mockService.stubbedResult = .sample(assets: .samplePage(count: 5))
        sut.handleOnAppear()

        // When - call again
        sut.handleOnAppear()

        // Wait
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then - should only load once
        XCTAssertEqual(mockService.fetchAssetsCallCount, 1)
    }

    func testLoadFirstPage_onError_setsErrorState() async throws {
        // Given - create a paginator with no retries for faster test
        let noRetryPaginator = Paginator<TimelineAssetDTO>(
            configuration: PaginatorConfiguration(
                itemsPerPage: 10,
                prefetchOffset: 2,
                maxRetryAttempts: 0,  // No retries
                retryBaseDelay: 0.1,
                maxRetryDelay: 0.1
            )
        )

        let viewModel = TimelineViewModel(
            timelineService: mockService,
            pagination: noRetryPaginator,
            carouselId: "test-carousel",
            errorLoggingService: mockErrorLoggingService
        )

        let testError = NSError(domain: "test", code: 500, userInfo: [NSLocalizedDescriptionKey: "Server error"])
        mockService.stubbedError = testError

        // When
        viewModel.loadFirstPage()
        try await Task.sleep(nanoseconds: 200_000_000) // Wait for single attempt

        // Then
        if case .error = viewModel.state {
            // Success - error state reached
        } else {
            XCTFail("Expected error state, got \(viewModel.state)")
        }

        // Verify error was logged
        XCTAssertFalse(mockErrorLoggingService.loggedErrors.isEmpty)
    }

    func testLoadFirstPage_storesCarouselConfig() async throws {
        // Given
        let config = CarouselConfigDTO(
            timestampFormat: "{DD}/{MM}/{YYYY}",
            showName: true,
            carouselAutoPlay: true,
            carouselAutoPlayInterval: 5.0,
            name: "Test Carousel",
            showTimestamps: true,
            mapBrandNameToProductName: false,
            swipeUpText: nil,
            sponsorship: nil
        )
        mockService.stubbedResult = .sample(
            assets: .samplePage(count: 3),
            carouselConfig: config
        )

        // When
        sut.loadFirstPage()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(sut.carouselConfig.name, "Test Carousel")
        XCTAssertEqual(sut.carouselConfig.carouselAutoPlay, true)
    }

    // MARK: - Carousel Items Tests

    func testCarouselItems_withContent_returnsItemsWithLoadingSkeleton() async throws {
        // Given - partial page (has more pages)
        let assets: [TimelineAssetDTO] = .samplePage(count: 10)
        mockService.stubbedResult = .sample(assets: assets)

        // When
        sut.loadFirstPage()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then - should have 10 content items + 1 loading skeleton
        let items = sut.carouselItems
        XCTAssertEqual(items.count, 11)
        XCTAssertTrue(items.last?.isLoading ?? false)
    }

    func testCarouselItems_whenNoMorePages_noLoadingSkeleton() async throws {
        // Given - partial page (no more pages)
        let assets: [TimelineAssetDTO] = .samplePage(count: 5)
        mockService.stubbedResult = .sample(assets: assets)

        // When
        sut.loadFirstPage()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then - should have 5 content items, no loading skeleton
        let items = sut.carouselItems
        XCTAssertEqual(items.count, 5)
        XCTAssertFalse(items.last?.isLoading ?? true)
    }

    // MARK: - Page Change Tests

    func testHandlePageChange_marksInitialStateAsFalse() async throws {
        // Given
        mockService.stubbedResult = .sample(assets: .samplePage(count: 10))
        sut.loadFirstPage()
        try await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(sut.isInitialCarouselState)

        // When
        sut.handlePageChange(to: 1)

        // Then
        XCTAssertFalse(sut.isInitialCarouselState)
    }

    func testHandlePageChange_toZero_keepsinitialStateTrue() async throws {
        // Given
        mockService.stubbedResult = .sample(assets: .samplePage(count: 10))
        sut.loadFirstPage()
        try await Task.sleep(nanoseconds: 100_000_000)

        // When - change to index 0
        sut.handlePageChange(to: 0)

        // Then - should still be initial state
        XCTAssertTrue(sut.isInitialCarouselState)
    }

    // MARK: - Asset Appeared Tests

    func testHandleAssetAppeared_tracksOnlyOnce() async throws {
        // Given
        mockService.stubbedResult = .sample(assets: .samplePage(count: 3))
        sut.loadFirstPage()
        try await Task.sleep(nanoseconds: 100_000_000)

        let asset = TimelineAssetDTO.sample(id: "test-asset", position: 0)

        // When - call multiple times
        sut.handleAssetAppeared(asset)
        sut.handleAssetAppeared(asset)
        sut.handleAssetAppeared(asset)

        // Then - delegate called only once
        XCTAssertEqual(mockAnalyticDelegate.viewedAssets.count, 1)
    }

    func testHandleAssetAppeared_setsIsInitialViewCorrectly() async throws {
        // Given
        mockService.stubbedResult = .sample(assets: .samplePage(count: 3))
        sut.loadFirstPage()
        try await Task.sleep(nanoseconds: 100_000_000)

        let asset1 = TimelineAssetDTO.sample(id: "asset-1", position: 0)
        let asset2 = TimelineAssetDTO.sample(id: "asset-2", position: 1)

        // When - first asset appears (initial state)
        sut.handleAssetAppeared(asset1)

        // Then
        XCTAssertTrue(mockAnalyticDelegate.viewedAssets[0].isInitialView)

        // When - user scrolls, then second asset appears
        sut.handlePageChange(to: 1)
        sut.handleAssetAppeared(asset2)

        // Then - not initial view anymore
        XCTAssertFalse(mockAnalyticDelegate.viewedAssets[1].isInitialView)
    }

    // MARK: - Carousel Viewed Tests

    func testHandleCarouselViewed_notifiesDelegate() async throws {
        // Given
        let assets: [TimelineAssetDTO] = .samplePage(count: 3)
        mockService.stubbedResult = .sample(assets: assets)
        sut.loadFirstPage()
        try await Task.sleep(nanoseconds: 100_000_000)

        // When
        sut.handleCarouselViewed()

        // Then
        XCTAssertEqual(mockAnalyticDelegate.viewedCarouselAssets.count, 1)
        XCTAssertEqual(mockAnalyticDelegate.viewedCarouselAssets[0].count, 3)
    }

    func testHandleCarouselViewed_whenEmpty_doesNotNotify() {
        // Given - empty state
        XCTAssertEqual(sut.state, .idle)

        // When
        sut.handleCarouselViewed()

        // Then
        XCTAssertTrue(mockAnalyticDelegate.viewedCarouselAssets.isEmpty)
    }

    // MARK: - Like Tests

    func testHandleAssetLiked_notifiesDelegate() {
        // Given
        let asset = TimelineAssetDTO.sample()

        // When
        sut.handleAssetLiked(asset)

        // Then
        XCTAssertEqual(mockAnalyticDelegate.likedAssets.count, 1)
        XCTAssertEqual(mockAnalyticDelegate.likedAssets[0].id, asset.id)
    }

    func testIsAssetLiked_usesLikeStateProvider() {
        // Given
        sut.likeStateProvider = { assetId in
            assetId == "liked-asset"
        }

        // Then
        XCTAssertTrue(sut.isAssetLiked("liked-asset"))
        XCTAssertFalse(sut.isAssetLiked("other-asset"))
    }

    func testIsAssetLiked_withoutProvider_returnsFalse() {
        XCTAssertFalse(sut.isAssetLiked("any-asset"))
    }

    // MARK: - Detail Open/Close Tests

    func testHandleDetailOpened_notifiesDelegateWithParentUrl() async throws {
        // Given
        let assetWithCTA = TimelineAssetDTO.sampleWithCTA(url: "https://example.com/parent")
        mockService.stubbedResult = .sample(assets: [assetWithCTA])
        sut.loadFirstPage()
        try await Task.sleep(nanoseconds: 100_000_000)

        // When
        sut.handleDetailOpened()

        // Then
        XCTAssertEqual(mockAnalyticDelegate.detailOpenedParentUrls.count, 1)
        XCTAssertEqual(mockAnalyticDelegate.detailOpenedParentUrls[0], "https://example.com/parent")
    }

    func testHandleDetailClosed_calculatesOpenDuration() async throws {
        // Given
        let asset = TimelineAssetDTO.sampleWithCTA(url: "https://example.com")
        mockService.stubbedResult = .sample(assets: [asset])
        sut.loadFirstPage()
        try await Task.sleep(nanoseconds: 100_000_000)

        // When
        sut.handleDetailOpened()
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms
        sut.handleDetailClosed()

        // Then
        XCTAssertEqual(mockAnalyticDelegate.detailClosedEvents.count, 1)
        XCTAssertGreaterThan(mockAnalyticDelegate.detailClosedEvents[0].durationMs, 0)
    }

    // MARK: - Asset View Duration Tests

    func testHandleAssetViewStarted_tracksStartTime() async throws {
        // Given
        let asset = TimelineAssetDTO.sample(position: 0)
        mockService.stubbedResult = .sample(assets: [asset])
        sut.loadFirstPage()
        try await Task.sleep(nanoseconds: 100_000_000)

        // When
        sut.handleAssetViewStarted(at: 0)

        // Then
        XCTAssertEqual(mockAnalyticDelegate.assetViewStartedEvents.count, 1)
        XCTAssertEqual(mockAnalyticDelegate.assetViewStartedEvents[0].asset.id, asset.id)
    }

    func testHandleAssetViewEnded_calculatesViewDuration() async throws {
        // Given
        let asset = TimelineAssetDTO.sample(position: 0)
        mockService.stubbedResult = .sample(assets: [asset])
        sut.loadFirstPage()
        try await Task.sleep(nanoseconds: 100_000_000)

        // When
        sut.handleAssetViewStarted(at: 0)
        try await Task.sleep(nanoseconds: 50_000_000) // 50ms
        sut.handleAssetViewEnded()

        // Then
        XCTAssertEqual(mockAnalyticDelegate.assetViewEndedEvents.count, 1)
        XCTAssertGreaterThan(mockAnalyticDelegate.assetViewEndedEvents[0].durationMs, 0)
    }

    func testHandleAssetViewStarted_endsPreviousView() async throws {
        // Given
        let assets: [TimelineAssetDTO] = .samplePage(count: 2)
        mockService.stubbedResult = .sample(assets: assets)
        sut.loadFirstPage()
        try await Task.sleep(nanoseconds: 100_000_000)

        // When - start viewing first, then immediately start second
        sut.handleAssetViewStarted(at: 0)
        sut.handleAssetViewStarted(at: 1)

        // Then - first view should be ended
        XCTAssertEqual(mockAnalyticDelegate.assetViewEndedEvents.count, 1)
        XCTAssertEqual(mockAnalyticDelegate.assetViewStartedEvents.count, 2)
    }

    // MARK: - CTA Button Tests

    func testHandleCtaButtonTap_notifiesDelegate() {
        // Given
        let asset = TimelineAssetDTO.sampleWithCTA(url: "https://example.com/cta")
        let url = URL(string: "https://example.com/cta")!

        // When
        sut.handleCtaButtonTap(asset: asset, url: url)

        // Then
        XCTAssertEqual(mockAnalyticDelegate.ctaClickedEvents.count, 1)
        XCTAssertEqual(mockAnalyticDelegate.ctaClickedEvents[0].url, "https://example.com/cta")
    }

    func testHandleCtaButtonTap_withNilUrl_doesNotNotify() {
        // Given
        let asset = TimelineAssetDTO.sample()

        // When
        sut.handleCtaButtonTap(asset: asset, url: nil)

        // Then
        XCTAssertTrue(mockAnalyticDelegate.ctaClickedEvents.isEmpty)
    }

    // MARK: - Product CTA Tests

    func testHandleProductCtaTap_notifiesDelegate() {
        // Given
        let asset = TimelineAssetDTO.sample()
        let product = ProductDTO.sampleFull
        let url = URL(string: "https://example.com/product")!

        // When
        sut.handleProductCtaTap(product: product, asset: asset, url: url)

        // Then
        XCTAssertEqual(mockAnalyticDelegate.productClickEvents.count, 1)
        XCTAssertEqual(mockAnalyticDelegate.productClickEvents[0].url, "https://example.com/product")
    }

    // MARK: - Share Tests

    func testHandleAssetShared_notifiesDelegate() {
        // Given
        let asset = TimelineAssetDTO.sample(position: 5)

        // When
        sut.handleAssetShared(asset)

        // Then
        XCTAssertEqual(mockAnalyticDelegate.shareEvents.count, 1)
        XCTAssertEqual(mockAnalyticDelegate.shareEvents[0].position, 5)
    }

    // MARK: - Product CTA Edge Cases

    func testHandleProductCtaTap_withNilUrl_doesNotNotify() {
        // Given
        let asset = TimelineAssetDTO.sample()
        let product = ProductDTO.sampleFull

        // When
        sut.handleProductCtaTap(product: product, asset: asset, url: nil)

        // Then
        XCTAssertTrue(mockAnalyticDelegate.productClickEvents.isEmpty)
    }

    // MARK: - Carousel Sponsorship Tests

    func testHandleCarouselSponsorshipClicked_notifiesDelegate() {
        // When
        sut.handleCarouselSponsorshipClicked(
            placement: .topLogo,
            sponsorshipUrl: "https://sponsor.com"
        )

        // Then
        XCTAssertEqual(mockAnalyticDelegate.carouselSponsorshipClickEvents.count, 1)
        XCTAssertEqual(mockAnalyticDelegate.carouselSponsorshipClickEvents[0].url, "https://sponsor.com")
    }

    func testHandleCarouselSponsorshipClicked_withNilUrl_notifiesDelegate() {
        // When
        sut.handleCarouselSponsorshipClicked(placement: .topLogo, sponsorshipUrl: nil)

        // Then
        XCTAssertEqual(mockAnalyticDelegate.carouselSponsorshipClickEvents.count, 1)
        XCTAssertNil(mockAnalyticDelegate.carouselSponsorshipClickEvents[0].url)
    }

    // MARK: - Asset Sponsorship Tests

    func testHandleAssetSponsorshipClicked_notifiesDelegate() {
        // Given
        let asset = TimelineAssetDTO.sample()

        // When
        sut.handleAssetSponsorshipClicked(
            asset: asset,
            placement: .badgeLogo,
            position: .top,
            clickPosition: .top,
            sponsorshipUrl: "https://sponsor.com/asset"
        )

        // Then
        XCTAssertEqual(mockAnalyticDelegate.assetSponsorshipClickEvents.count, 1)
        XCTAssertEqual(mockAnalyticDelegate.assetSponsorshipClickEvents[0].url, "https://sponsor.com/asset")
    }

    func testHandleAssetSponsorshipClicked_withNilPositions_notifiesDelegate() {
        // Given
        let asset = TimelineAssetDTO.sample()

        // When
        sut.handleAssetSponsorshipClicked(
            asset: asset,
            placement: .bannerLogo,
            position: nil,
            clickPosition: nil,
            sponsorshipUrl: nil
        )

        // Then
        XCTAssertEqual(mockAnalyticDelegate.assetSponsorshipClickEvents.count, 1)
        XCTAssertNil(mockAnalyticDelegate.assetSponsorshipClickEvents[0].position)
        XCTAssertNil(mockAnalyticDelegate.assetSponsorshipClickEvents[0].clickPosition)
        XCTAssertNil(mockAnalyticDelegate.assetSponsorshipClickEvents[0].url)
    }

    // MARK: - Detail View Disappear Analytics Tests

    func testHandleDetailViewDisappear_endsCurrentAssetView() async throws {
        // Given
        let asset = TimelineAssetDTO.sample()
        mockService.stubbedResult = .sample(assets: [asset])
        sut.loadFirstPage()
        try await Task.sleep(nanoseconds: 100_000_000)

        sut.enableAutoAdvance()
        // enableAutoAdvance calls handleCurrentAssetChanged which calls handleAssetViewStarted
        let startedCount = mockAnalyticDelegate.assetViewStartedEvents.count
        XCTAssertEqual(startedCount, 1)

        // When
        sut.handleDetailViewDisappear()

        // Then - should have ended the current view
        XCTAssertEqual(mockAnalyticDelegate.assetViewEndedEvents.count, 1)
    }

    func testHandleDetailViewDisappear_tracksDetailClosed() async throws {
        // Given
        let asset = TimelineAssetDTO.sample()
        mockService.stubbedResult = .sample(assets: [asset])
        sut.loadFirstPage()
        try await Task.sleep(nanoseconds: 100_000_000)

        sut.enableAutoAdvance() // This triggers handleDetailOpened via loadNextPage
        sut.handleDetailOpened()

        // When
        sut.handleDetailViewDisappear()

        // Then
        XCTAssertFalse(mockAnalyticDelegate.detailClosedEvents.isEmpty)
    }

    // MARK: - Asset View Edge Cases

    func testHandleAssetViewEnded_withoutStarted_isNoOp() {
        // When - end without starting
        sut.handleAssetViewEnded()

        // Then
        XCTAssertTrue(mockAnalyticDelegate.assetViewEndedEvents.isEmpty)
    }

    func testHandleDetailClosed_withoutOpened_isNoOp() {
        // When - close without opening
        sut.handleDetailClosed()

        // Then
        XCTAssertTrue(mockAnalyticDelegate.detailClosedEvents.isEmpty)
    }

    // MARK: - Auto-Advance Tests

    func testEnableAutoAdvance_startsAutoAdvanceForImages() async throws {
        // Given - image asset
        let imageAsset = TimelineAssetDTO.sample(type: .image, position: 0)
        mockService.stubbedResult = .sample(assets: [imageAsset])
        sut.loadFirstPage()
        try await Task.sleep(nanoseconds: 100_000_000)

        // When
        sut.enableAutoAdvance()

        // Then - should track asset view
        XCTAssertEqual(mockAnalyticDelegate.assetViewStartedEvents.count, 1)
    }

    func testHandleVideoFinished_withAutoAdvanceEnabled_advancesToNext() async throws {
        // Given - video asset followed by image
        let video = TimelineAssetDTO.sampleVideo(id: "video-1", position: 0)
        let image = TimelineAssetDTO.sample(id: "image-1", position: 1)
        mockService.stubbedResult = .sample(assets: [video, image])
        sut.loadFirstPage()
        try await Task.sleep(nanoseconds: 100_000_000)

        sut.enableAutoAdvance()
        XCTAssertEqual(sut.currentPageIndex, 0)

        // When
        sut.handleVideoFinished()

        // Then
        XCTAssertEqual(sut.currentPageIndex, 1)
    }

    func testHandleVideoFinished_withAutoAdvanceDisabled_doesNotAdvance() async throws {
        // Given
        let video = TimelineAssetDTO.sampleVideo(position: 0)
        let image = TimelineAssetDTO.sample(position: 1)
        mockService.stubbedResult = .sample(assets: [video, image])
        sut.loadFirstPage()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Auto-advance not enabled
        XCTAssertEqual(sut.currentPageIndex, 0)

        // When
        sut.handleVideoFinished()

        // Then - should not advance
        XCTAssertEqual(sut.currentPageIndex, 0)
    }

    func testHandleDetailViewDisappear_cancelsAutoAdvance() async throws {
        // Given
        let asset = TimelineAssetDTO.sample()
        mockService.stubbedResult = .sample(assets: [asset])
        sut.loadFirstPage()
        try await Task.sleep(nanoseconds: 100_000_000)

        sut.enableAutoAdvance()

        // When
        sut.handleDetailViewDisappear()

        // Then - should not advance after video finished
        sut.handleVideoFinished()
        XCTAssertEqual(sut.currentPageIndex, 0)
    }

    // MARK: - Pagination Tests

    func testHandlePageChange_nearEnd_loadsNextPage() async throws {
        // Given - first page loaded
        mockService.stubbedResult = .sample(assets: .samplePage(count: 10))
        sut.loadFirstPage()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Prepare second page
        mockService.stubbedResult = .sample(assets: .samplePage(count: 10, startPosition: 10))

        // When - scroll near end (prefetchOffset is 2)
        sut.handlePageChange(to: 8)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then - should have loaded second page
        XCTAssertEqual(mockService.fetchAssetsCallCount, 2)
    }

    func testNewAssetsLoaded_notifiesDelegate() async throws {
        // Given
        let assets: [TimelineAssetDTO] = .samplePage(count: 5)
        mockService.stubbedResult = .sample(assets: assets)

        // When
        sut.loadFirstPage()
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(mockAnalyticDelegate.loadedAssets.count, 1)
        XCTAssertEqual(mockAnalyticDelegate.loadedAssets[0].count, 5)
    }

    // MARK: - Make View Data Tests

    func testMakeViewData_createsPollViewModel() async throws {
        // Given
        let pollAsset = TimelineAssetDTO.samplePoll()
        mockService.stubbedResult = .sample(assets: [pollAsset])
        sut.loadFirstPage()
        try await Task.sleep(nanoseconds: 100_000_000)

        // When
        let viewData = sut.makeViewData(from: pollAsset)

        // Then
        XCTAssertNotNil(viewData.pollViewModel)
    }

    func testMakeViewData_reusesPollViewModelFromStore() async throws {
        // Given
        let pollAsset = TimelineAssetDTO.samplePoll()
        mockService.stubbedResult = .sample(assets: [pollAsset])
        sut.loadFirstPage()
        try await Task.sleep(nanoseconds: 100_000_000)

        // When - create view data twice
        let viewData1 = sut.makeViewData(from: pollAsset)
        let viewData2 = sut.makeViewData(from: pollAsset)

        // Then - should be same instance
        XCTAssertTrue(viewData1.pollViewModel === viewData2.pollViewModel)
    }
}
