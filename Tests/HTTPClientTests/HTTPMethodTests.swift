import XCTest
@testable import HTTPClient

final class HTTPMethodTests: XCTestCase {

    // MARK: - Idempotent

    func testIsIdempotent_getHeadPutDelete_areIdempotent() {
        XCTAssertTrue(HTTPMethod.get.isIdempotent)
        XCTAssertTrue(HTTPMethod.head.isIdempotent)
        XCTAssertTrue(HTTPMethod.put.isIdempotent)
        XCTAssertTrue(HTTPMethod.delete.isIdempotent)
    }

    func testIsIdempotent_postPatchOptions_areNotIdempotent() {
        XCTAssertFalse(HTTPMethod.post.isIdempotent)
        XCTAssertFalse(HTTPMethod.patch.isIdempotent)
        XCTAssertFalse(HTTPMethod.options.isIdempotent)
        XCTAssertFalse(HTTPMethod.trace.isIdempotent)
        XCTAssertFalse(HTTPMethod.connect.isIdempotent)
    }

    // MARK: - Description

    func testDescription_isUppercased() {
        XCTAssertEqual(HTTPMethod.get.description, "GET")
        XCTAssertEqual(HTTPMethod.post.description, "POST")
        XCTAssertEqual(HTTPMethod.delete.description, "DELETE")
        XCTAssertEqual(HTTPMethod.patch.description, "PATCH")
    }

    // MARK: - CaseIterable

    func testCaseIterable_containsAllMethods() {
        XCTAssertEqual(HTTPMethod.allCases.count, 9)
    }

    // MARK: - Raw Values

    func testRawValues_areLowercase() {
        XCTAssertEqual(HTTPMethod.get.rawValue, "get")
        XCTAssertEqual(HTTPMethod.post.rawValue, "post")
        XCTAssertEqual(HTTPMethod.put.rawValue, "put")
    }
}
