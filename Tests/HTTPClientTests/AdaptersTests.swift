import XCTest
@testable import HTTPClient

// MARK: - Test Request Types

private struct JSONTestRequest: Request {
    typealias Response = TestModel
    var method: HTTPMethod { .get }
    var path: String? { "/test" }
}

private struct TextTestRequest: Request {
    typealias Response = TextResponse
    var method: HTTPMethod { .get }
    var path: String? { "/text" }
}

private struct EmptyTestRequest: Request {
    typealias Response = EmptyResponse
    var method: HTTPMethod { .post }
    var path: String? { "/empty" }
}

private struct PostTestRequest: Request {
    typealias Response = EmptyResponse
    var method: HTTPMethod { .post }
    var path: String? { "/submit" }
    var headers: Headers? { ["Content-Type": "application/json", "X-Custom": "value"] }
    var body: Encodable? { TestBody(name: "test", count: 42) }
    var query: Query? { ["page": 1, "sort": "name"] }
}

private struct TestModel: Decodable, Equatable {
    let id: Int
    let name: String
}

private struct TestBody: Codable {
    let name: String
    let count: Int
}

// MARK: - DefaultRequestAdapter Tests

final class DefaultRequestAdapterTests: XCTestCase {

    // MARK: - Basic Request Building

    func testTransform_setsHTTPMethod() async throws {
        let adapter = DefaultRequestAdapter(base: URL(string: "https://api.example.com"))
        let request = PostTestRequest()

        let urlRequest = try await adapter.transform(request)

        XCTAssertEqual(urlRequest.httpMethod, "POST")
    }

    func testTransform_buildsURL_withPath() async throws {
        let adapter = DefaultRequestAdapter(base: URL(string: "https://api.example.com"))
        let request = JSONTestRequest()

        let urlRequest = try await adapter.transform(request)

        XCTAssertEqual(urlRequest.url?.path, "/test")
    }

    func testTransform_buildsURL_withVersion() async throws {
        let adapter = DefaultRequestAdapter(base: URL(string: "https://api.example.com"), version: "v2")
        let request = JSONTestRequest()

        let urlRequest = try await adapter.transform(request)

        XCTAssertTrue(urlRequest.url!.absoluteString.contains("/v2/test"))
    }

    func testTransform_setsHeaders() async throws {
        let adapter = DefaultRequestAdapter(base: URL(string: "https://api.example.com"))
        let request = PostTestRequest()

        let urlRequest = try await adapter.transform(request)

        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "X-Custom"), "value")
    }

    func testTransform_encodesBody() async throws {
        let adapter = DefaultRequestAdapter(base: URL(string: "https://api.example.com"))
        let request = PostTestRequest()

        let urlRequest = try await adapter.transform(request)

        XCTAssertNotNil(urlRequest.httpBody)
        let decoded = try JSONDecoder().decode(TestBody.self, from: urlRequest.httpBody!)
        XCTAssertEqual(decoded.name, "test")
        XCTAssertEqual(decoded.count, 42)
    }

    func testTransform_addsQueryParameters() async throws {
        let adapter = DefaultRequestAdapter(base: URL(string: "https://api.example.com"))
        let request = PostTestRequest()

        let urlRequest = try await adapter.transform(request)

        let components = URLComponents(url: urlRequest.url!, resolvingAgainstBaseURL: false)!
        XCTAssertTrue(components.queryItems!.contains { $0.name == "page" && $0.value == "1" })
        XCTAssertTrue(components.queryItems!.contains { $0.name == "sort" && $0.value == "name" })
    }

    func testTransform_nilBase_throws() async {
        let adapter = DefaultRequestAdapter(base: nil)
        let request = JSONTestRequest()

        do {
            _ = try await adapter.transform(request)
            XCTFail("Expected error")
        } catch {
            // Expected
        }
    }
}

// MARK: - TextResponseAdapter Tests

final class TextResponseAdapterTests: XCTestCase {

    func testTransform_textResponse_returnsText() async throws {
        let adapter = TextResponseAdapter()
        let data = "Hello, World!".data(using: .utf8)
        let response = Response(data, nil, nil)

        let result: TextResponse? = try await adapter.transform(response, for: TextTestRequest())

        XCTAssertEqual(result?.text, "Hello, World!")
    }

    func testTransform_textResponse_nilData_returnsEmptyText() async throws {
        let adapter = TextResponseAdapter()
        let response = Response(nil, nil, nil)

        let result: TextResponse? = try await adapter.transform(response, for: TextTestRequest())

        XCTAssertEqual(result?.text, "")
    }

    func testTransform_nonTextResponse_fallsToNext() async throws {
        let mockNext = MockResponseAdapter()
        let adapter = TextResponseAdapter(next: mockNext)
        let response = Response("{}".data(using: .utf8), nil, nil)

        let _: TestModel? = try await adapter.transform(response, for: JSONTestRequest())

        XCTAssertTrue(mockNext.transformCalled)
    }

    func testTransform_nonTextResponse_noNext_throws() async {
        let adapter = TextResponseAdapter(next: nil)
        let response = Response("{}".data(using: .utf8), nil, nil)

        do {
            let _: TestModel? = try await adapter.transform(response, for: JSONTestRequest())
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is ResponseAdapterError)
        }
    }

    func testTransform_withError_throwsTransportError() async {
        let adapter = TextResponseAdapter()
        let error = NSError(domain: "test", code: 1)
        let response = Response(nil, nil, error)

        do {
            let _: TextResponse? = try await adapter.transform(response, for: TextTestRequest())
            XCTFail("Expected error")
        } catch {
            if case ApiError.transport = error {} else {
                XCTFail("Expected transport error, got \(error)")
            }
        }
    }
}

// MARK: - JSONResponseAdapter Tests

final class JSONResponseAdapterTests: XCTestCase {

    func testTransform_validJSON_decodesSuccessfully() async throws {
        let adapter = JSONResponseAdapter()
        let json = """
        {"id": 1, "name": "Test"}
        """.data(using: .utf8)
        let response = Response(json, nil, nil)

        let result: TestModel? = try await adapter.transform(response, for: JSONTestRequest())

        XCTAssertEqual(result, TestModel(id: 1, name: "Test"))
    }

    func testTransform_nilData_returnsNil() async throws {
        let adapter = JSONResponseAdapter()
        let response = Response(nil, nil, nil)

        let result: TestModel? = try await adapter.transform(response, for: JSONTestRequest())

        XCTAssertNil(result)
    }

    func testTransform_emptyResponse_returnsEmptyResponse() async throws {
        let adapter = JSONResponseAdapter()
        let response = Response(Data(), nil, nil)

        let result: EmptyResponse? = try await adapter.transform(response, for: EmptyTestRequest())

        XCTAssertNotNil(result)
    }

    func testTransform_invalidJSON_fallsToNextAdapter() async throws {
        let mockNext = MockResponseAdapter()
        let adapter = JSONResponseAdapter(next: mockNext)
        let response = Response("not json".data(using: .utf8), nil, nil)

        let _: TestModel? = try await adapter.transform(response, for: JSONTestRequest())

        XCTAssertTrue(mockNext.transformCalled)
    }

    func testTransform_invalidJSON_noNext_throws() async {
        let adapter = JSONResponseAdapter(next: nil)
        let response = Response("not json".data(using: .utf8), nil, nil)

        do {
            let _: TestModel? = try await adapter.transform(response, for: JSONTestRequest())
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is ResponseAdapterError)
        }
    }

    func testTransform_withError_throwsTransportError() async {
        let adapter = JSONResponseAdapter()
        let error = NSError(domain: "test", code: 1)
        let response = Response(nil, nil, error)

        do {
            let _: TestModel? = try await adapter.transform(response, for: JSONTestRequest())
            XCTFail("Expected error")
        } catch {
            if case ApiError.transport = error {} else {
                XCTFail("Expected transport error, got \(error)")
            }
        }
    }
}

// MARK: - Adapter Chain Tests

final class AdapterChainTests: XCTestCase {

    func testJSONToTextChain_jsonRequest_decodedByJSON() async throws {
        let textAdapter = TextResponseAdapter()
        let jsonAdapter = JSONResponseAdapter(next: textAdapter)

        let json = """
        {"id": 42, "name": "Chain"}
        """.data(using: .utf8)
        let response = Response(json, nil, nil)

        let result: TestModel? = try await jsonAdapter.transform(response, for: JSONTestRequest())

        XCTAssertEqual(result, TestModel(id: 42, name: "Chain"))
    }

    func testJSONToTextChain_textRequest_fallsToText() async throws {
        let textAdapter = TextResponseAdapter()
        let jsonAdapter = JSONResponseAdapter(next: textAdapter)

        let data = "plain text".data(using: .utf8)
        let response = Response(data, nil, nil)

        let result: TextResponse? = try await jsonAdapter.transform(response, for: TextTestRequest())

        XCTAssertEqual(result?.text, "plain text")
    }
}

// MARK: - Mock Response Adapter

private final class MockResponseAdapter: ResponseAdapter {
    var next: ResponseAdapter?
    var transformCalled = false

    func transform<T: Request>(_ response: Response, for request: T) async throws -> T.Response? {
        transformCalled = true
        return nil
    }
}
