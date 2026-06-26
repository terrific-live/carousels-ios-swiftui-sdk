import XCTest
@testable import HTTPClient

final class HeaderInterceptorTests: XCTestCase {

    // MARK: - Header Injection

    func testIntercept_addsHeaderToRequest() async throws {
        let interceptor = HeaderInterceptor { ("Authorization", "Bearer abc123") }
        var request = URLRequest(url: URL(string: "https://example.com")!)

        try await interceptor.intercept(&request)

        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer abc123")
    }

    func testIntercept_preservesExistingHeaders() async throws {
        let interceptor = HeaderInterceptor { ("X-New", "new-value") }
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request.setValue("existing", forHTTPHeaderField: "X-Existing")

        try await interceptor.intercept(&request)

        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Existing"), "existing")
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-New"), "new-value")
    }

    func testIntercept_dynamicInjector_calledEachTime() async throws {
        var callCount = 0
        let interceptor = HeaderInterceptor {
            callCount += 1
            return ("X-Count", "\(callCount)")
        }

        var request1 = URLRequest(url: URL(string: "https://example.com")!)
        try await interceptor.intercept(&request1)
        XCTAssertEqual(request1.value(forHTTPHeaderField: "X-Count"), "1")

        var request2 = URLRequest(url: URL(string: "https://example.com")!)
        try await interceptor.intercept(&request2)
        XCTAssertEqual(request2.value(forHTTPHeaderField: "X-Count"), "2")
    }

    // MARK: - Error Handling

    func testIntercept_injectorThrows_propagatesError() async {
        let interceptor = HeaderInterceptor {
            throw NSError(domain: "auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Token expired"])
        }
        var request = URLRequest(url: URL(string: "https://example.com")!)

        do {
            try await interceptor.intercept(&request)
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual((error as NSError).code, 401)
        }
    }

    // MARK: - Integration with Interceptor Stack

    func testHeaderInterceptor_inStack_addsHeader() async throws {
        let stack = Interceptor()
        stack.push(HeaderInterceptor { ("X-API-Key", "key-456") })

        var request = URLRequest(url: URL(string: "https://example.com")!)
        try await stack.applyRequest(&request)

        XCTAssertEqual(request.value(forHTTPHeaderField: "X-API-Key"), "key-456")
    }

    func testMultipleHeaderInterceptors_allApplied() async throws {
        let stack = Interceptor()
        stack.push(HeaderInterceptor { ("X-First", "1") })
        stack.push(HeaderInterceptor { ("X-Second", "2") })

        var request = URLRequest(url: URL(string: "https://example.com")!)
        try await stack.applyRequest(&request)

        XCTAssertEqual(request.value(forHTTPHeaderField: "X-First"), "1")
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Second"), "2")
    }
}

// MARK: - AnyEncodable Tests

final class AnyEncodableTests: XCTestCase {

    func testEncode_encodesWrappedValue() throws {
        let value = TestPayload(id: 1, message: "hello")
        let wrapped = AnyEncodable(value)

        let data = try JSONEncoder().encode(wrapped)
        let decoded = try JSONDecoder().decode(TestPayload.self, from: data)

        XCTAssertEqual(decoded.id, 1)
        XCTAssertEqual(decoded.message, "hello")
    }

    func testEncode_encodesString() throws {
        let wrapped = AnyEncodable("plain text")

        let data = try JSONEncoder().encode(wrapped)
        let decoded = try JSONDecoder().decode(String.self, from: data)

        XCTAssertEqual(decoded, "plain text")
    }

    func testEncode_encodesArray() throws {
        let wrapped = AnyEncodable([1, 2, 3])

        let data = try JSONEncoder().encode(wrapped)
        let decoded = try JSONDecoder().decode([Int].self, from: data)

        XCTAssertEqual(decoded, [1, 2, 3])
    }
}

private struct TestPayload: Codable, Equatable {
    let id: Int
    let message: String
}
