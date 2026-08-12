import XCTest
@testable import HTTPClient

// MARK: - Interceptor Stack Tests

final class InterceptorTests: XCTestCase {

    // MARK: - Push & Apply Request

    func testApplyRequest_executesInterceptor() async throws {
        let interceptor = Interceptor()
        let mock = MockRequestInterceptor(headerKey: "X-Test", headerValue: "123")
        interceptor.push(mock)

        var request = URLRequest(url: URL(string: "https://example.com")!)
        try await interceptor.applyRequest(&request)

        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Test"), "123")
    }

    func testApplyRequest_multipleInterceptors_executedInReverseOrder() async throws {
        let interceptor = Interceptor()
        let first = MockRequestInterceptor(headerKey: "X-Order", headerValue: "first")
        let second = MockRequestInterceptor(headerKey: "X-Order", headerValue: "second")

        interceptor.push(first)
        interceptor.push(second)

        var request = URLRequest(url: URL(string: "https://example.com")!)
        try await interceptor.applyRequest(&request)

        // LIFO: second runs first, then first overwrites → "first"
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Order"), "first")
    }

    func testApplyRequest_noInterceptors_doesNothing() async throws {
        let interceptor = Interceptor()
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request.setValue("original", forHTTPHeaderField: "X-Test")

        try await interceptor.applyRequest(&request)

        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Test"), "original")
    }

    // MARK: - Push & Apply Response

    func testApplyResponse_executesInterceptor() async throws {
        let interceptor = Interceptor()
        let mock = MockResponseInterceptorImpl()
        interceptor.push(mock)

        var request = URLRequest(url: URL(string: "https://example.com")!)
        var response = Response("data".data(using: .utf8), nil, nil)
        let transport = MockNetworkTransport()

        try await interceptor.applyResponse(&response, for: &request, in: transport)

        XCTAssertTrue(mock.interceptCalled)
    }

    // MARK: - Clean

    func testClean_removesAllInterceptors() async throws {
        let interceptor = Interceptor()
        let mock = MockRequestInterceptor(headerKey: "X-Clean", headerValue: "should-not-appear")
        interceptor.push(mock)

        interceptor.clean()

        var request = URLRequest(url: URL(string: "https://example.com")!)
        try await interceptor.applyRequest(&request)

        XCTAssertNil(request.value(forHTTPHeaderField: "X-Clean"))
    }

    // MARK: - Chainable Push

    func testPush_isChainable() async throws {
        let interceptor = Interceptor()
        interceptor
            .push(MockRequestInterceptor(headerKey: "A", headerValue: "1"))
            .push(MockRequestInterceptor(headerKey: "B", headerValue: "2"))

        var request = URLRequest(url: URL(string: "https://example.com")!)
        try await interceptor.applyRequest(&request)

        // Both interceptors applied — chain works
        XCTAssertNotNil(request.value(forHTTPHeaderField: "A"))
        XCTAssertNotNil(request.value(forHTTPHeaderField: "B"))
    }

    // MARK: - Mixed Interceptors

    func testMixedInterceptors_requestAndResponse() async throws {
        let interceptor = Interceptor()
        let requestInterceptor = MockRequestInterceptor(headerKey: "X-Auth", headerValue: "token")
        let responseInterceptor = MockResponseInterceptorImpl()

        interceptor.push(requestInterceptor)
        interceptor.push(responseInterceptor as ResponseInterceptor)

        // Apply request interceptor
        var request = URLRequest(url: URL(string: "https://example.com")!)
        try await interceptor.applyRequest(&request)
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Auth"), "token")

        // Apply response interceptor
        var response = Response()
        let transport = MockNetworkTransport()
        try await interceptor.applyResponse(&response, for: &request, in: transport)
        XCTAssertTrue(responseInterceptor.interceptCalled)
    }
}

// MARK: - HTTPResponseErrorInterceptor Tests

final class HTTPResponseErrorInterceptorTests: XCTestCase {

    private let interceptor = HTTPResponseErrorInterceptor()

    // MARK: - Success Responses

    func testIntercept_200_doesNotThrow() async throws {
        var response = makeResponse(statusCode: 200)
        var request = URLRequest(url: URL(string: "https://example.com")!)
        let transport = MockNetworkTransport()

        try await interceptor.intercept(&response, for: &request, in: transport)
        // No throw = success
    }

    func testIntercept_201_doesNotThrow() async throws {
        var response = makeResponse(statusCode: 201)
        var request = URLRequest(url: URL(string: "https://example.com")!)
        let transport = MockNetworkTransport()

        try await interceptor.intercept(&response, for: &request, in: transport)
    }

    func testIntercept_304_doesNotThrow() async throws {
        var response = makeResponse(statusCode: 304)
        var request = URLRequest(url: URL(string: "https://example.com")!)
        let transport = MockNetworkTransport()

        try await interceptor.intercept(&response, for: &request, in: transport)
    }

    // MARK: - Error Responses

    func testIntercept_400_throwsHTTPError() async {
        var response = makeResponse(statusCode: 400, body: "Bad Request")
        var request = URLRequest(url: URL(string: "https://example.com")!)
        let transport = MockNetworkTransport()

        do {
            try await interceptor.intercept(&response, for: &request, in: transport)
            XCTFail("Expected HTTPError")
        } catch let error as HTTPError {
            XCTAssertEqual(error.statusCode, 400)
            XCTAssertEqual(error.responseBody, "Bad Request")
        } catch {
            XCTFail("Expected HTTPError, got \(error)")
        }
    }

    func testIntercept_404_throwsHTTPError() async {
        var response = makeResponse(statusCode: 404)
        var request = URLRequest(url: URL(string: "https://example.com")!)
        let transport = MockNetworkTransport()

        do {
            try await interceptor.intercept(&response, for: &request, in: transport)
            XCTFail("Expected HTTPError")
        } catch let error as HTTPError {
            XCTAssertEqual(error.statusCode, 404)
            XCTAssertTrue(error.isNotFound)
        } catch {
            XCTFail("Expected HTTPError, got \(error)")
        }
    }

    func testIntercept_500_throwsHTTPError() async {
        var response = makeResponse(statusCode: 500, body: "Internal Server Error")
        var request = URLRequest(url: URL(string: "https://example.com")!)
        let transport = MockNetworkTransport()

        do {
            try await interceptor.intercept(&response, for: &request, in: transport)
            XCTFail("Expected HTTPError")
        } catch let error as HTTPError {
            XCTAssertEqual(error.statusCode, 500)
            XCTAssertTrue(error.isServerError)
        } catch {
            XCTFail("Expected HTTPError, got \(error)")
        }
    }

    // MARK: - Non-HTTP Response

    func testIntercept_nonHTTPResponse_doesNotThrow() async throws {
        var response = Response("data".data(using: .utf8), nil, nil)
        var request = URLRequest(url: URL(string: "https://example.com")!)
        let transport = MockNetworkTransport()

        try await interceptor.intercept(&response, for: &request, in: transport)
        // Non-HTTP URLResponse is ignored
    }

    // MARK: - Helpers

    private func makeResponse(statusCode: Int, body: String? = nil) -> Response {
        let httpResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )
        let data = body?.data(using: .utf8)
        return Response(data, httpResponse, nil)
    }
}

// MARK: - Mock Helpers

private struct MockRequestInterceptor: RequestInterceptor {
    let headerKey: String
    let headerValue: String

    func intercept(_ request: inout URLRequest) async throws {
        request.setValue(headerValue, forHTTPHeaderField: headerKey)
    }
}

private final class MockResponseInterceptorImpl: ResponseInterceptor {
    var interceptCalled = false

    func intercept(
        _ response: inout Response,
        for request: inout URLRequest,
        in transport: NetworkTransport
    ) async throws {
        interceptCalled = true
    }
}

private final class MockNetworkTransport: NetworkTransport {
    @discardableResult
    func send(_ request: URLRequest, callback: @escaping (sending Response) -> Void) -> CancellableObject {
        callback(Response())
        return MockCancellable()
    }

    func send(_ request: URLRequest) async -> Response {
        Response()
    }
}

private final class MockCancellable: CancellableObject {
    func cancel() {}
}
