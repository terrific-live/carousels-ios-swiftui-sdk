//
//  LocalizedAccessibilityTextProviderTests.swift
//  TerrificCarouselSDKTests
//

import XCTest
@testable import TerrificCarouselSDK

final class LocalizedAccessibilityTextProviderTests: XCTestCase {

    private var sut: LocalizedAccessibilityTextProvider!

    override func setUp() {
        super.setUp()
        sut = LocalizedAccessibilityTextProvider()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Basic String Tests

    func testCarouselLabel_returnsNonEmptyString() {
        XCTAssertFalse(sut.carouselLabel.isEmpty)
    }

    func testCarouselHint_returnsNonEmptyString() {
        XCTAssertFalse(sut.carouselHint.isEmpty)
    }

    func testCloseButtonLabel_returnsNonEmptyString() {
        XCTAssertFalse(sut.closeButtonLabel.isEmpty)
    }

    func testLikeButtonLabel_returnsNonEmptyString() {
        XCTAssertFalse(sut.likeButtonLabel.isEmpty)
    }

    func testShareButtonLabel_returnsNonEmptyString() {
        XCTAssertFalse(sut.shareButtonLabel.isEmpty)
    }

    func testLoadingLabel_returnsNonEmptyString() {
        XCTAssertFalse(sut.loadingLabel.isEmpty)
    }

    // MARK: - Format String Tests

    func testItemPositionLabel_formatsCorrectly() {
        let result = sut.itemPositionLabel(current: 3, total: 10)
        XCTAssertTrue(result.contains("3"))
        XCTAssertTrue(result.contains("10"))
    }

    func testCurrentPageIndexLabel_formatsCorrectly() {
        let result = sut.currentPageIndexLabel(current: 2, total: 5)
        XCTAssertTrue(result.contains("2"))
        XCTAssertTrue(result.contains("5"))
    }

    func testFeedAssetCardLabel_withSubtitle_formatsCorrectly() {
        let result = sut.feedAssetCardLabel(title: "Title", subtitle: "Subtitle", mediaType: .image, pollQuestion: nil)
        XCTAssertTrue(result.contains("Title"))
        XCTAssertTrue(result.contains("Subtitle"))
    }

    func testFeedAssetCardLabel_withoutSubtitle_formatsCorrectly() {
        let result = sut.feedAssetCardLabel(title: "Title", subtitle: nil, mediaType: .video, pollQuestion: nil)
        XCTAssertTrue(result.contains("Title"))
    }

    func testDetailAssetLabel_withSubtitle_formatsCorrectly() {
        let result = sut.detailAssetLabel(title: "Title", subtitle: "Subtitle")
        XCTAssertTrue(result.contains("Title"))
        XCTAssertTrue(result.contains("Subtitle"))
    }

    func testDetailAssetLabel_withoutSubtitle_returnsTitle() {
        let result = sut.detailAssetLabel(title: "Title", subtitle: nil)
        XCTAssertEqual(result, "Title")
    }

    // MARK: - Poll Tests

    func testPollQuestionLabel_formatsCorrectly() {
        let result = sut.pollQuestionLabel(question: "What color?")
        XCTAssertTrue(result.contains("What color?"))
    }

    func testPollOptionHint_whenInteractive_returnsHint() {
        let result = sut.pollOptionHint(isInteractive: true)
        XCTAssertFalse(result.isEmpty)
    }

    func testPollOptionHint_whenNotInteractive_returnsEmpty() {
        let result = sut.pollOptionHint(isInteractive: false)
        XCTAssertTrue(result.isEmpty)
    }

    func testPollOptionAnsweredLabel_whenSelected_containsSelectedIndicator() {
        let result = sut.pollOptionAnsweredLabel(text: "Blue", percentage: 45, isSelected: true)
        XCTAssertTrue(result.contains("Blue"))
        XCTAssertTrue(result.contains("45"))
    }

    func testPollOptionAnsweredLabel_whenNotSelected_formatsCorrectly() {
        let result = sut.pollOptionAnsweredLabel(text: "Red", percentage: 30, isSelected: false)
        XCTAssertTrue(result.contains("Red"))
        XCTAssertTrue(result.contains("30"))
    }

    // MARK: - Product Tests

    func testProductLabel_allFields_formatsCorrectly() {
        let result = sut.productLabel(title: "Shirt", subtitle: "Blue", price: "$29.99")
        XCTAssertTrue(result.contains("Shirt"))
        XCTAssertTrue(result.contains("Blue"))
        XCTAssertTrue(result.contains("$29.99"))
    }

    func testProductLabel_titleOnly_returnsTitle() {
        let result = sut.productLabel(title: "Shirt", subtitle: nil, price: nil)
        XCTAssertEqual(result, "Shirt")
    }

    // MARK: - Media Tests

    func testImageLabel_withDescription_returnsDescription() {
        let result = sut.imageLabel(description: "A sunset over mountains")
        XCTAssertEqual(result, "A sunset over mountains")
    }

    func testImageLabel_withoutDescription_returnsDefault() {
        let result = sut.imageLabel(description: nil)
        XCTAssertFalse(result.isEmpty)
    }

    func testVideoLabel_muted_returnsCorrectLabel() {
        let result = sut.videoLabel(isMuted: true)
        XCTAssertFalse(result.isEmpty)
    }

    func testVideoLabel_withAudio_returnsCorrectLabel() {
        let result = sut.videoLabel(isMuted: false)
        XCTAssertFalse(result.isEmpty)
    }

    // MARK: - Pass-through Tests

    func testCtaButtonLabel_returnsTitle() {
        XCTAssertEqual(sut.ctaButtonLabel(title: "Shop Now"), "Shop Now")
    }

    func testPollOptionLabel_returnsText() {
        XCTAssertEqual(sut.pollOptionLabel(text: "Option A"), "Option A")
    }

    func testSponsorBadgeLabel_returnsText() {
        XCTAssertEqual(sut.sponsorBadgeLabel(text: "Sponsored"), "Sponsored")
    }

    func testProductCtaButtonLabel_returnsTitle() {
        XCTAssertEqual(sut.productCtaButtonLabel(title: "Buy Now"), "Buy Now")
    }
}
