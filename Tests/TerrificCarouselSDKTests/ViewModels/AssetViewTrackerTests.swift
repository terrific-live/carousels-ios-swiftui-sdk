//
//  AssetViewTrackerTests.swift
//  TerrificCarouselSDKTests
//

import XCTest
@testable import TerrificCarouselSDK

final class AssetViewTrackerTests: XCTestCase {

    // MARK: - Initial State

    func test_initialState_isNotTracking() {
        let sut = AssetViewTracker()

        XCTAssertFalse(sut.isTracking)
        XCTAssertNil(sut.startTime)
        XCTAssertNil(sut.assetIndex)
        XCTAssertEqual(sut.backgroundDuration, 0)
    }

    // MARK: - Start

    func test_start_beginsTracking() {
        var sut = AssetViewTracker()

        sut.start(at: 3)

        XCTAssertTrue(sut.isTracking)
        XCTAssertNotNil(sut.startTime)
        XCTAssertEqual(sut.assetIndex, 3)
        XCTAssertEqual(sut.backgroundDuration, 0)
    }

    func test_start_resetsBackgroundDuration() {
        var sut = AssetViewTracker()

        sut.start(at: 0)
        sut.addBackgroundTime(5.0)
        sut.start(at: 1)

        XCTAssertEqual(sut.backgroundDuration, 0)
        XCTAssertEqual(sut.assetIndex, 1)
    }

    // MARK: - End

    func test_end_whenNotTracking_returnsNil() {
        var sut = AssetViewTracker()

        let result = sut.end()

        XCTAssertNil(result)
    }

    func test_end_returnsIndexAndDurations() {
        var sut = AssetViewTracker()
        sut.start(at: 5)

        // Small sleep to ensure measurable duration
        Thread.sleep(forTimeInterval: 0.05)

        let result = sut.end()

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.index, 5)
        XCTAssertGreaterThan(result!.viewDurationMs, 0)
        XCTAssertGreaterThan(result!.netoWatchTimeMs, 0)
    }

    func test_end_resetsState() {
        var sut = AssetViewTracker()
        sut.start(at: 2)

        _ = sut.end()

        XCTAssertFalse(sut.isTracking)
        XCTAssertNil(sut.startTime)
        XCTAssertNil(sut.assetIndex)
        XCTAssertEqual(sut.backgroundDuration, 0)
    }

    func test_end_calledTwice_returnsNilOnSecondCall() {
        var sut = AssetViewTracker()
        sut.start(at: 0)

        let first = sut.end()
        let second = sut.end()

        XCTAssertNotNil(first)
        XCTAssertNil(second)
    }

    // MARK: - Background Time

    func test_addBackgroundTime_accumulatesWhenTracking() {
        var sut = AssetViewTracker()
        sut.start(at: 0)

        sut.addBackgroundTime(2.0)
        sut.addBackgroundTime(3.0)

        XCTAssertEqual(sut.backgroundDuration, 5.0)
    }

    func test_addBackgroundTime_ignoredWhenNotTracking() {
        var sut = AssetViewTracker()

        sut.addBackgroundTime(10.0)

        XCTAssertEqual(sut.backgroundDuration, 0)
    }

    func test_end_subtractsBackgroundTimeFromNetoDuration() {
        var sut = AssetViewTracker()
        sut.start(at: 0)

        Thread.sleep(forTimeInterval: 0.1)
        sut.addBackgroundTime(0.05)

        let result = sut.end()

        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result!.viewDurationMs, result!.netoWatchTimeMs)
    }

    func test_end_netoWatchTimeNeverNegative() {
        var sut = AssetViewTracker()
        sut.start(at: 0)

        // Add more background time than actual elapsed time
        sut.addBackgroundTime(999.0)

        let result = sut.end()

        XCTAssertNotNil(result)
        XCTAssertEqual(result!.netoWatchTimeMs, 0)
    }
}
