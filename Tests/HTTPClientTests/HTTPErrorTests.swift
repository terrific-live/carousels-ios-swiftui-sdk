import XCTest
@testable import HTTPClient

final class HTTPErrorTests: XCTestCase {

    // MARK: - Status Code Classification

    func testIsClientError_4xx_returnsTrue() {
        for code in 400..<500 {
            let error = HTTPError(statusCode: code)
            XCTAssertTrue(error.isClientError, "Status \(code) should be client error")
        }
    }

    func testIsClientError_non4xx_returnsFalse() {
        XCTAssertFalse(HTTPError(statusCode: 200).isClientError)
        XCTAssertFalse(HTTPError(statusCode: 302).isClientError)
        XCTAssertFalse(HTTPError(statusCode: 500).isClientError)
    }

    func testIsServerError_5xx_returnsTrue() {
        for code in 500..<600 {
            let error = HTTPError(statusCode: code)
            XCTAssertTrue(error.isServerError, "Status \(code) should be server error")
        }
    }

    func testIsServerError_non5xx_returnsFalse() {
        XCTAssertFalse(HTTPError(statusCode: 200).isServerError)
        XCTAssertFalse(HTTPError(statusCode: 404).isServerError)
    }

    func testIsNotFound_404_returnsTrue() {
        XCTAssertTrue(HTTPError(statusCode: 404).isNotFound)
    }

    func testIsNotFound_other_returnsFalse() {
        XCTAssertFalse(HTTPError(statusCode: 403).isNotFound)
        XCTAssertFalse(HTTPError(statusCode: 500).isNotFound)
    }

    func testIsUnauthorized_401_returnsTrue() {
        XCTAssertTrue(HTTPError(statusCode: 401).isUnauthorized)
    }

    func testIsUnauthorized_other_returnsFalse() {
        XCTAssertFalse(HTTPError(statusCode: 403).isUnauthorized)
    }

    func testIsForbidden_403_returnsTrue() {
        XCTAssertTrue(HTTPError(statusCode: 403).isForbidden)
    }

    func testIsForbidden_other_returnsFalse() {
        XCTAssertFalse(HTTPError(statusCode: 401).isForbidden)
    }

    // MARK: - Error Description

    func testErrorDescription_statusCodeOnly() {
        let error = HTTPError(statusCode: 500)
        XCTAssertEqual(error.errorDescription, "HTTP Error 500")
    }

    func testErrorDescription_withResponseBody() {
        let error = HTTPError(statusCode: 404, responseBody: "Not Found")
        XCTAssertEqual(error.errorDescription, "HTTP Error 404: Not Found")
    }

    func testErrorDescription_withEmptyBody_omitsBody() {
        let error = HTTPError(statusCode: 500, responseBody: "")
        XCTAssertEqual(error.errorDescription, "HTTP Error 500")
    }

    // MARK: - Init

    func testInit_storesAllProperties() {
        let underlying = NSError(domain: "test", code: 1)
        let error = HTTPError(statusCode: 422, responseBody: "Invalid", underlyingError: underlying)

        XCTAssertEqual(error.statusCode, 422)
        XCTAssertEqual(error.responseBody, "Invalid")
        XCTAssertNotNil(error.underlyingError)
    }
}
