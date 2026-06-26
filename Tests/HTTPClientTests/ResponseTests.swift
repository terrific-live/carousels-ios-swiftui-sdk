import XCTest
@testable import HTTPClient

final class ResponseTests: XCTestCase {

    // MARK: - Init

    func testInit_storesProperties() {
        let data = "test".data(using: .utf8)
        let urlResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let error = NSError(domain: "test", code: 1)

        let response = Response(data, urlResponse, error)

        XCTAssertEqual(response.data, data)
        XCTAssertNotNil(response.urlResponse)
        XCTAssertNotNil(response.error)
    }

    func testInit_defaults_areNil() {
        let response = Response()
        XCTAssertNil(response.data)
        XCTAssertNil(response.urlResponse)
        XCTAssertNil(response.error)
    }

    // MARK: - Resolved

    func testResolved_withError_throws() {
        let error = NSError(domain: "test", code: 42)
        let response = Response(nil, nil, error)

        XCTAssertThrowsError(try response.resolved())
    }

    func testResolved_withoutError_returnsDataAndResponse() throws {
        let data = "body".data(using: .utf8)
        let urlResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let response = Response(data, urlResponse, nil)

        let (resolvedData, resolvedResponse) = try response.resolved()
        XCTAssertEqual(resolvedData, data)
        XCTAssertNotNil(resolvedResponse)
    }

    func testResolved_nilDataNoError_returnsNils() throws {
        let response = Response()
        let (data, urlResponse) = try response.resolved()
        XCTAssertNil(data)
        XCTAssertNil(urlResponse)
    }
}

// MARK: - ResponseType Tests
final class ResponseTypeTests: XCTestCase {

    // MARK: - Success Codes

    func testFromCode_2xx_isSucceed() {
        for code in 200..<300 {
            let type = ResponseType(fromCode: code)
            XCTAssertEqual(type, .succeed, "Code \(code) should be succeed")
        }
    }

    // MARK: - Specific Error Codes

    func testFromCode_304_isNotModified() {
        XCTAssertEqual(ResponseType(fromCode: 304), .notModified)
    }

    func testFromCode_400_isBadRequest() {
        XCTAssertEqual(ResponseType(fromCode: 400), .badRequest)
    }

    func testFromCode_401_isUnauthorized() {
        XCTAssertEqual(ResponseType(fromCode: 401), .unauthorized)
    }

    func testFromCode_403_isForbidden() {
        XCTAssertEqual(ResponseType(fromCode: 403), .forbidden)
    }

    func testFromCode_404_isNotFound() {
        XCTAssertEqual(ResponseType(fromCode: 404), .notFound)
    }

    func testFromCode_408_isRequestTimeOut() {
        XCTAssertEqual(ResponseType(fromCode: 408), .requestTimeOut)
    }

    func testFromCode_409_isConflict() {
        XCTAssertEqual(ResponseType(fromCode: 409), .conflict)
    }

    func testFromCode_422_isUnprocessable() {
        XCTAssertEqual(ResponseType(fromCode: 422), .unprocessable)
    }

    func testFromCode_429_isRateLimitExceed() {
        XCTAssertEqual(ResponseType(fromCode: 429), .rateLimitExceed)
    }

    func testFromCode_500_isInternalError() {
        XCTAssertEqual(ResponseType(fromCode: 500), .internalError)
    }

    func testFromCode_502_isBadGateway() {
        XCTAssertEqual(ResponseType(fromCode: 502), .badGateway)
    }

    func testFromCode_503_isServiceUnavailable() {
        XCTAssertEqual(ResponseType(fromCode: 503), .serviceUnavailable)
    }

    func testFromCode_504_isGatewayTimeOut() {
        XCTAssertEqual(ResponseType(fromCode: 504), .gatewayTimeOut)
    }

    func testFromCode_unknownCode_isUnknownError() {
        XCTAssertEqual(ResponseType(fromCode: 999), .unknownError)
    }

    // MARK: - Collections

    func testGoodResponses_containsExpectedTypes() {
        XCTAssertTrue(ResponseType.goodResponses.contains(.succeed))
        XCTAssertTrue(ResponseType.goodResponses.contains(.notModified))
        XCTAssertTrue(ResponseType.goodResponses.contains(.canceled))
    }

    func testClientErrors_containsExpectedTypes() {
        let clientErrors = ResponseType.clientErrors
        XCTAssertTrue(clientErrors.contains(.badRequest))
        XCTAssertTrue(clientErrors.contains(.unauthorized))
        XCTAssertTrue(clientErrors.contains(.forbidden))
        XCTAssertTrue(clientErrors.contains(.notFound))
        XCTAssertTrue(clientErrors.contains(.rateLimitExceed))
    }

    func testServerErrors_containsExpectedTypes() {
        let serverErrors = ResponseType.serverErrors
        XCTAssertTrue(serverErrors.contains(.internalError))
        XCTAssertTrue(serverErrors.contains(.badGateway))
        XCTAssertTrue(serverErrors.contains(.serviceUnavailable))
        XCTAssertTrue(serverErrors.contains(.gatewayTimeOut))
    }
}
