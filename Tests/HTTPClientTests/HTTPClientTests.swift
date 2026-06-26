import XCTest
@testable import HTTPClient

// MARK: - Test Request Types

private struct TestJSONRequest: Request {
    typealias Response = TestUser
    var method: HTTPMethod { .get }
    var path: String? { "/users/1" }
}

private struct TestPostRequest: Request {
    typealias Response = EmptyResponse
    var method: HTTPMethod { .post }
    var path: String? { "/users" }
    var body: Encodable? { TestUserBody(name: "Alice") }
    var headers: Headers? { ["Content-Type": "application/json"] }
}

private struct TestQueryRequest: Request {
    typealias Response = TestUser
    var method: HTTPMethod { .get }
    var path: String? { "/users" }
    var query: Query? { ["page": 2, "limit": 10] }
}

private struct TestTextRequest: Request {
    typealias Response = TextResponse
    var method: HTTPMethod { .get }
    var path: String? { "/health" }
}

private struct TestUser: Decodable, Equatable {
    let id: Int
    let name: String
}

private struct TestUserBody: Codable {
    let name: String
}

// MARK: - Client Initialization Tests

final class ClientInitializationTests: XCTestCase {

    func testInit_withBaseURL() {
        let client = Client(base: "https://api.example.com")
        XCTAssertNotNil(client)
    }

    func testInit_withBaseURLAndVersion() {
        let client = Client(base: "https://api.example.com", version: "v2")
        XCTAssertNotNil(client)
    }

    func testInit_withCustomTransport() {
        let transport = StubNetworkTransport()
        let client = Client(base: "https://api.example.com", version: nil, transport: transport)
        XCTAssertTrue(client.transport is StubNetworkTransport)
    }

    func testInit_withAdapters() {
        let transport = StubNetworkTransport()
        let requestAdapter = DefaultRequestAdapter(base: URL(string: "https://api.example.com"))
        let responseAdapter = JSONResponseAdapter()
        let client = Client(transport: transport, requestAdapter: requestAdapter, responseAdapter: responseAdapter)
        XCTAssertNotNil(client)
    }
}

// MARK: - Client Send Tests

final class ClientSendTests: XCTestCase {

    private var transport: StubNetworkTransport!
    private var client: Client!

    override func setUp() {
        super.setUp()
        transport = StubNetworkTransport()
        client = Client(base: "https://api.example.com", version: nil, transport: transport)
    }

    override func tearDown() {
        transport = nil
        client = nil
        super.tearDown()
    }

    // MARK: - Successful Responses

    func testSend_jsonResponse_decodesSuccessfully() async throws {
        let json = #"{"id": 1, "name": "Alice"}"#
        transport.stubResponse = Response(json.data(using: .utf8), makeHTTPResponse(200), nil)

        let result = try await client.send(TestJSONRequest())

        XCTAssertEqual(result, TestUser(id: 1, name: "Alice"))
    }

    func testSend_emptyResponse_returnsEmptyResponse() async throws {
        transport.stubResponse = Response(Data(), makeHTTPResponse(200), nil)

        let result = try await client.send(TestPostRequest())

        XCTAssertNotNil(result)
    }

    func testSend_textResponse_returnsText() async throws {
        let text = "OK"
        transport.stubResponse = Response(text.data(using: .utf8), makeHTTPResponse(200), nil)

        let result = try await client.send(TestTextRequest())

        XCTAssertEqual(result?.text, "OK")
    }

    func testSend_nilData_returnsNil() async throws {
        transport.stubResponse = Response(nil, makeHTTPResponse(200), nil)

        let result = try await client.send(TestJSONRequest())

        XCTAssertNil(result)
    }

    // MARK: - Request Construction

    func testSend_setsCorrectPath() async throws {
        transport.stubResponse = Response(#"{"id":1,"name":"A"}"#.data(using: .utf8), makeHTTPResponse(200), nil)

        _ = try await client.send(TestJSONRequest())

        XCTAssertTrue(transport.lastRequest?.url?.path.contains("/users/1") ?? false)
    }

    func testSend_setsCorrectHTTPMethod() async throws {
        transport.stubResponse = Response(Data(), makeHTTPResponse(200), nil)

        _ = try await client.send(TestPostRequest())

        XCTAssertEqual(transport.lastRequest?.httpMethod, "POST")
    }

    func testSend_setsHeaders() async throws {
        transport.stubResponse = Response(Data(), makeHTTPResponse(200), nil)

        _ = try await client.send(TestPostRequest())

        XCTAssertEqual(transport.lastRequest?.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }

    func testSend_encodesBody() async throws {
        transport.stubResponse = Response(Data(), makeHTTPResponse(200), nil)

        _ = try await client.send(TestPostRequest())

        XCTAssertNotNil(transport.lastRequest?.httpBody)
        let decoded = try JSONDecoder().decode(TestUserBody.self, from: transport.lastRequest!.httpBody!)
        XCTAssertEqual(decoded.name, "Alice")
    }

    func testSend_includesQueryParameters() async throws {
        transport.stubResponse = Response(#"{"id":1,"name":"A"}"#.data(using: .utf8), makeHTTPResponse(200), nil)

        _ = try await client.send(TestQueryRequest())

        let urlString = transport.lastRequest?.url?.absoluteString ?? ""
        XCTAssertTrue(urlString.contains("page=2"))
        XCTAssertTrue(urlString.contains("limit=10"))
    }

    // MARK: - Transport Error

    func testSend_transportError_throwsApiError() async {
        let networkError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        transport.stubResponse = Response(nil, nil, networkError)

        do {
            _ = try await client.send(TestJSONRequest())
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is ApiError)
        }
    }

    // MARK: - Interceptor Integration

    func testSend_requestInterceptor_modifiesRequest() async throws {
        transport.stubResponse = Response(#"{"id":1,"name":"A"}"#.data(using: .utf8), makeHTTPResponse(200), nil)
        client.interceptor.push(HeaderInterceptor { ("Authorization", "Bearer token-123") })

        _ = try await client.send(TestJSONRequest())

        XCTAssertEqual(transport.lastRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer token-123")
    }

    func testSend_responseErrorInterceptor_throwsOnErrorStatus() async {
        transport.stubResponse = Response("Not Found".data(using: .utf8), makeHTTPResponse(404), nil)
        client.interceptor.push(HTTPResponseErrorInterceptor() as ResponseInterceptor)

        do {
            _ = try await client.send(TestJSONRequest())
            XCTFail("Expected HTTPError")
        } catch let error as HTTPError {
            XCTAssertEqual(error.statusCode, 404)
            XCTAssertTrue(error.isNotFound)
        } catch {
            XCTFail("Expected HTTPError, got \(error)")
        }
    }

    func testSend_multipleInterceptors_allApplied() async throws {
        transport.stubResponse = Response(#"{"id":1,"name":"A"}"#.data(using: .utf8), makeHTTPResponse(200), nil)
        client.interceptor
            .push(HeaderInterceptor { ("X-First", "1") })
            .push(HeaderInterceptor { ("X-Second", "2") })

        _ = try await client.send(TestJSONRequest())

        XCTAssertEqual(transport.lastRequest?.value(forHTTPHeaderField: "X-First"), "1")
        XCTAssertEqual(transport.lastRequest?.value(forHTTPHeaderField: "X-Second"), "2")
    }

    // MARK: - Helpers

    private func makeHTTPResponse(_ statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(
            url: URL(string: "https://api.example.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }
}

// MARK: - Stub Network Transport

private final class StubNetworkTransport: NetworkTransport {
    var stubResponse = Response()
    var lastRequest: URLRequest?

    @discardableResult
    func send(_ request: URLRequest, callback: @escaping (sending Response) -> Void) -> CancellableObject {
        lastRequest = request
        callback(stubResponse)
        return StubCancellable()
    }

    func send(_ request: URLRequest) async -> Response {
        lastRequest = request
        return stubResponse
    }
}

private final class StubCancellable: CancellableObject {
    func cancel() {}
}
