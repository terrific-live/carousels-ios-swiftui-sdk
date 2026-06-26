import XCTest
@testable import HTTPClient

final class URLQueryTests: XCTestCase {

    private let baseURL = URL(string: "https://api.example.com/v1")!

    // MARK: - Basic Query Parameters

    func testWithQuery_singleParameter() {
        let url = baseURL.with(query: ["key": "value"])
        XCTAssertEqual(url?.absoluteString, "https://api.example.com/v1?key=value")
    }

    func testWithQuery_multipleParameters_sortedAlphabetically() {
        let url = baseURL.with(query: ["b": "2", "a": "1"])
        XCTAssertEqual(url?.absoluteString, "https://api.example.com/v1?a=1&b=2")
    }

    // MARK: - Nil Values

    func testWithQuery_nilValue_isOmitted() {
        let url = baseURL.with(query: ["present": "yes", "absent": nil])
        XCTAssertEqual(url?.absoluteString, "https://api.example.com/v1?present=yes")
    }

    func testWithQuery_allNilValues_returnsSameURL() {
        let url = baseURL.with(query: ["a": nil, "b": nil])
        XCTAssertEqual(url, baseURL)
    }

    // MARK: - Array Values

    func testWithQuery_arrayValue_expandsToMultipleItems() {
        let url = baseURL.with(query: ["tag": ["a", "b", "c"]])

        let components = URLComponents(url: url!, resolvingAgainstBaseURL: false)!
        let tagItems = components.queryItems!.filter { $0.name == "tag" }
        XCTAssertEqual(tagItems.count, 3)
        XCTAssertEqual(tagItems.map(\.value), ["a", "b", "c"])
    }

    // MARK: - Existing Query

    func testWithQuery_preservesExistingQueryItems() {
        let urlWithExisting = URL(string: "https://api.example.com/v1?existing=true")!
        let url = urlWithExisting.with(query: ["new": "param"])

        let components = URLComponents(url: url!, resolvingAgainstBaseURL: false)!
        XCTAssertEqual(components.queryItems?.count, 2)
        XCTAssertTrue(components.queryItems!.contains { $0.name == "existing" && $0.value == "true" })
        XCTAssertTrue(components.queryItems!.contains { $0.name == "new" && $0.value == "param" })
    }

    // MARK: - Empty Query

    func testWithQuery_emptyDictionary_returnsSameURL() {
        let url = baseURL.with(query: [:])
        XCTAssertEqual(url, baseURL)
    }

    // MARK: - Numeric Values

    func testWithQuery_numericValue_convertsToString() {
        let url = baseURL.with(query: ["page": 5])
        XCTAssertEqual(url?.absoluteString, "https://api.example.com/v1?page=5")
    }
}
