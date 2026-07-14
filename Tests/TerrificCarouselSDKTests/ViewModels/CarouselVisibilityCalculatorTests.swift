//
//  CarouselVisibilityCalculatorTests.swift
//  TerrificCarouselSDKTests
//

import XCTest
@testable import TerrificCarouselSDK

final class CarouselVisibilityCalculatorTests: XCTestCase {

    // MARK: - resolveSelectedIndex

    func test_emptyVisibilities_returnsNil() {
        let result = CarouselVisibilityCalculator.resolveSelectedIndex(
            visibilities: [:],
            currentIndex: 0
        )

        XCTAssertNil(result)
    }

    func test_allZeroVisibilities_returnsNil() {
        let result = CarouselVisibilityCalculator.resolveSelectedIndex(
            visibilities: [0: 0, 1: 0, 2: 0],
            currentIndex: 0
        )

        XCTAssertNil(result)
    }

    func test_currentIndexFullyVisible_returnsNil() {
        let result = CarouselVisibilityCalculator.resolveSelectedIndex(
            visibilities: [0: 100, 1: 100, 2: 50],
            currentIndex: 0
        )

        XCTAssertNil(result)
    }

    func test_currentIndexNearlyFullyVisible_returnsNil() {
        // 96 >= 100 * 0.95 = 95 → should keep current
        let result = CarouselVisibilityCalculator.resolveSelectedIndex(
            visibilities: [0: 96, 1: 100, 2: 50],
            currentIndex: 0
        )

        XCTAssertNil(result)
    }

    func test_currentIndexBelowThreshold_returnsNewIndex() {
        // 90 < 100 * 0.95 = 95 → should change
        let result = CarouselVisibilityCalculator.resolveSelectedIndex(
            visibilities: [0: 90, 1: 100, 2: 50],
            currentIndex: 0
        )

        XCTAssertEqual(result, 1)
    }

    func test_selectsLowestIndexAmongEquallyVisible() {
        let result = CarouselVisibilityCalculator.resolveSelectedIndex(
            visibilities: [2: 100, 3: 100, 5: 100],
            currentIndex: 0
        )

        XCTAssertEqual(result, 2)
    }

    func test_currentAlreadyMostVisible_returnsNil() {
        let result = CarouselVisibilityCalculator.resolveSelectedIndex(
            visibilities: [3: 200, 4: 150],
            currentIndex: 3
        )

        XCTAssertNil(result)
    }

    func test_singleItemVisible_selectsIt() {
        let result = CarouselVisibilityCalculator.resolveSelectedIndex(
            visibilities: [5: 100],
            currentIndex: 0
        )

        XCTAssertEqual(result, 5)
    }

    func test_currentIndexNotInVisibilities_selectsMostVisible() {
        let result = CarouselVisibilityCalculator.resolveSelectedIndex(
            visibilities: [1: 200, 2: 100],
            currentIndex: 0
        )

        XCTAssertEqual(result, 1)
    }

    // MARK: - VisibilityReporter.calculateVisibleWidth

    func test_fullyVisible_returnsFullWidth() {
        let frame = CGRect(x: 50, y: 0, width: 200, height: 100)
        let result = VisibilityReporter.calculateVisibleWidth(itemFrame: frame, containerWidth: 400)

        XCTAssertEqual(result, 200)
    }

    func test_partiallyVisibleLeft_returnsClippedWidth() {
        let frame = CGRect(x: -50, y: 0, width: 200, height: 100)
        let result = VisibilityReporter.calculateVisibleWidth(itemFrame: frame, containerWidth: 400)

        XCTAssertEqual(result, 150)
    }

    func test_partiallyVisibleRight_returnsClippedWidth() {
        let frame = CGRect(x: 300, y: 0, width: 200, height: 100)
        let result = VisibilityReporter.calculateVisibleWidth(itemFrame: frame, containerWidth: 400)

        XCTAssertEqual(result, 100)
    }

    func test_completelyOffscreen_returnsZero() {
        let frame = CGRect(x: -300, y: 0, width: 200, height: 100)
        let result = VisibilityReporter.calculateVisibleWidth(itemFrame: frame, containerWidth: 400)

        XCTAssertEqual(result, 0)
    }

    func test_completelyOffscreenRight_returnsZero() {
        let frame = CGRect(x: 500, y: 0, width: 200, height: 100)
        let result = VisibilityReporter.calculateVisibleWidth(itemFrame: frame, containerWidth: 400)

        XCTAssertEqual(result, 0)
    }
}
