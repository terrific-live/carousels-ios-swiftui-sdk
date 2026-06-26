import XCTest
@testable import HTTPClient

final class HeadersTests: XCTestCase {

    // MARK: - Init

    func testInit_withDictionary() {
        let headers = Headers(["Content-Type": "application/json"])
        XCTAssertEqual(headers.headers["Content-Type"], "application/json")
    }

    // MARK: - Dictionary Literal

    func testDictionaryLiteral_createsHeaders() {
        let headers: Headers = ["Accept": "text/html", "Authorization": "Bearer token"]
        XCTAssertEqual(headers.headers["Accept"], "text/html")
        XCTAssertEqual(headers.headers["Authorization"], "Bearer token")
    }

    func testDictionaryLiteral_empty() {
        let headers: Headers = [:]
        XCTAssertTrue(headers.headers.isEmpty)
    }

    // MARK: - ForEach

    func testForEach_iteratesOverAllHeaders() {
        let headers: Headers = ["A": "1", "B": "2"]
        var collected: [String: String] = [:]

        headers.forEach { key, value in
            collected[key] = value
        }

        XCTAssertEqual(collected, ["A": "1", "B": "2"])
    }

    // MARK: - Equatable

    func testEquatable_sameHeaders_areEqual() {
        let a = Headers(["X-Key": "value"])
        let b = Headers(["X-Key": "value"])
        XCTAssertEqual(a, b)
    }

    func testEquatable_differentHeaders_areNotEqual() {
        let a = Headers(["X-Key": "value1"])
        let b = Headers(["X-Key": "value2"])
        XCTAssertNotEqual(a, b)
    }

    // MARK: - Description

    func testDescription_formatsHeaderLines() {
        let headers = Headers(["Content-Type": "application/json"])
        XCTAssertTrue(headers.description.contains("Content-Type: application/json"))
    }
}
