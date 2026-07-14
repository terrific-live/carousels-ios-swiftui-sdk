//
//  DetailSessionTrackerTests.swift
//  TerrificCarouselSDKTests
//

import XCTest
@testable import TerrificCarouselSDK

final class DetailSessionTrackerTests: XCTestCase {

    // MARK: - Initial State

    func test_initialState_isNotTracking() {
        let sut = DetailSessionTracker()

        XCTAssertFalse(sut.isTracking)
        XCTAssertNil(sut.openedTime)
        XCTAssertEqual(sut.backgroundDuration, 0)
    }

    // MARK: - Open

    func test_open_beginsTracking() {
        var sut = DetailSessionTracker()

        sut.open()

        XCTAssertTrue(sut.isTracking)
        XCTAssertNotNil(sut.openedTime)
        XCTAssertEqual(sut.backgroundDuration, 0)
    }

    func test_open_resetsBackgroundDuration() {
        var sut = DetailSessionTracker()

        sut.open()
        sut.addBackgroundTime(5.0)
        sut.open()

        XCTAssertEqual(sut.backgroundDuration, 0)
    }

    // MARK: - Close

    func test_close_whenNotTracking_returnsNil() {
        var sut = DetailSessionTracker()

        let result = sut.close()

        XCTAssertNil(result)
    }

    func test_close_returnsDurations() {
        var sut = DetailSessionTracker()
        sut.open()

        Thread.sleep(forTimeInterval: 0.05)

        let result = sut.close()

        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result!.totalOpenDurationMs, 0)
        XCTAssertGreaterThan(result!.activeViewDurationMs, 0)
    }

    func test_close_resetsState() {
        var sut = DetailSessionTracker()
        sut.open()

        _ = sut.close()

        XCTAssertFalse(sut.isTracking)
        XCTAssertNil(sut.openedTime)
        XCTAssertEqual(sut.backgroundDuration, 0)
    }

    func test_close_calledTwice_returnsNilOnSecondCall() {
        var sut = DetailSessionTracker()
        sut.open()

        let first = sut.close()
        let second = sut.close()

        XCTAssertNotNil(first)
        XCTAssertNil(second)
    }

    // MARK: - Background Time

    func test_addBackgroundTime_accumulatesWhenTracking() {
        var sut = DetailSessionTracker()
        sut.open()

        sut.addBackgroundTime(2.0)
        sut.addBackgroundTime(3.0)

        XCTAssertEqual(sut.backgroundDuration, 5.0)
    }

    func test_addBackgroundTime_ignoredWhenNotTracking() {
        var sut = DetailSessionTracker()

        sut.addBackgroundTime(10.0)

        XCTAssertEqual(sut.backgroundDuration, 0)
    }

    func test_close_subtractsBackgroundTimeFromActiveDuration() {
        var sut = DetailSessionTracker()
        sut.open()

        Thread.sleep(forTimeInterval: 0.1)
        sut.addBackgroundTime(0.05)

        let result = sut.close()

        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result!.totalOpenDurationMs, result!.activeViewDurationMs)
    }

    func test_close_activeViewDurationNeverNegative() {
        var sut = DetailSessionTracker()
        sut.open()

        // Add more background time than actual elapsed time
        sut.addBackgroundTime(999.0)

        let result = sut.close()

        XCTAssertNotNil(result)
        XCTAssertEqual(result!.activeViewDurationMs, 0)
    }
}
