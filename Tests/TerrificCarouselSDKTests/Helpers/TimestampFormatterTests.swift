//
//  TimestampFormatterTests.swift
//  TerrificCarouselSDKTests
//

import XCTest
@testable import TerrificCarouselSDK

final class TimestampFormatterTests: XCTestCase {

    // MARK: - Test Date

    /// Fixed date: 2026-03-05 17:09:42 (UTC)
    private var testDate: Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 3
        components.day = 5
        components.hour = 17
        components.minute = 9
        components.second = 42
        components.timeZone = .current
        return Calendar.current.date(from: components)!
    }

    // MARK: - Default Format (nil / empty)

    func testFormat_nilFormatString_returnsDefaultFormat() {
        let result = TimestampFormatter.format(testDate, with: nil)

        // Default format uses locale DateFormatter: "<short date> | <short time>"
        XCTAssertTrue(result.contains(" | "), "Default format should contain ' | ' separator, got: \(result)")
        XCTAssertFalse(result.isEmpty)
    }

    func testFormat_emptyFormatString_returnsDefaultFormat() {
        let result = TimestampFormatter.format(testDate, with: "")

        XCTAssertTrue(result.contains(" | "), "Empty format string should fall back to default, got: \(result)")
    }

    // MARK: - Custom Format — Individual Placeholders

    func testFormat_dayPlaceholder() {
        let result = TimestampFormatter.format(testDate, with: "{DD}")
        XCTAssertEqual(result, "05")
    }

    func testFormat_monthPlaceholder() {
        let result = TimestampFormatter.format(testDate, with: "{MM}")
        XCTAssertEqual(result, "03")
    }

    func testFormat_fullYearPlaceholder() {
        let result = TimestampFormatter.format(testDate, with: "{YYYY}")
        XCTAssertEqual(result, "2026")
    }

    func testFormat_shortYearPlaceholder() {
        let result = TimestampFormatter.format(testDate, with: "{YY}")
        XCTAssertEqual(result, "26")
    }

    func testFormat_hourPlaceholder() {
        let result = TimestampFormatter.format(testDate, with: "{hh}")
        XCTAssertEqual(result, "17")
    }

    func testFormat_minutePlaceholder() {
        let result = TimestampFormatter.format(testDate, with: "{mm}")
        XCTAssertEqual(result, "09")
    }

    func testFormat_secondPlaceholder() {
        let result = TimestampFormatter.format(testDate, with: "{ss}")
        XCTAssertEqual(result, "42")
    }

    // MARK: - Custom Format — Combined Patterns

    func testFormat_dateSlashFormat() {
        let result = TimestampFormatter.format(testDate, with: "{DD}/{MM}/{YYYY}")
        XCTAssertEqual(result, "05/03/2026")
    }

    func testFormat_europeanDateTimeFormat() {
        let result = TimestampFormatter.format(testDate, with: "{DD}/{MM}/{YYYY} - {hh}h{mm}")
        XCTAssertEqual(result, "05/03/2026 - 17h09")
    }

    func testFormat_shortDateFormat() {
        let result = TimestampFormatter.format(testDate, with: "{DD}.{MM}.{YY}")
        XCTAssertEqual(result, "05.03.26")
    }

    func testFormat_timeOnlyFormat() {
        let result = TimestampFormatter.format(testDate, with: "{hh}:{mm}:{ss}")
        XCTAssertEqual(result, "17:09:42")
    }

    func testFormat_fullDateTimeFormat() {
        let result = TimestampFormatter.format(testDate, with: "{YYYY}-{MM}-{DD}T{hh}:{mm}:{ss}")
        XCTAssertEqual(result, "2026-03-05T17:09:42")
    }

    // MARK: - Edge Cases

    func testFormat_literalTextOnly_returnedAsIs() {
        let result = TimestampFormatter.format(testDate, with: "Hello World")
        XCTAssertEqual(result, "Hello World")
    }

    func testFormat_mixedLiteralsAndPlaceholders() {
        let result = TimestampFormatter.format(testDate, with: "Date: {DD}/{MM}")
        XCTAssertEqual(result, "Date: 05/03")
    }

    func testFormat_duplicatePlaceholders() {
        let result = TimestampFormatter.format(testDate, with: "{DD}-{DD}")
        XCTAssertEqual(result, "05-05")
    }

    func testFormat_zeroPaddedSingleDigits() {
        // Day=5, Month=3, Minute=9 should all be zero-padded
        let result = TimestampFormatter.format(testDate, with: "{DD} {MM} {mm}")
        XCTAssertEqual(result, "05 03 09")
    }
}
