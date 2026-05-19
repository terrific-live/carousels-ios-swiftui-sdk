//
//  MockNetworkTransport.swift
//  TerrificCarouselSDKTests
//

import Foundation
import Combine
import HTTPClient

// MARK: - MockCancellable
final class MockCancellable: Cancellable {
    func cancel() {}
}

// MARK: - MockNetworkTransport
/// Mock network transport for testing HTTP requests
final class MockNetworkTransport: NetworkTransport {

    // MARK: - Stubbed Response
    var stubbedData: Data?
    var stubbedResponse: URLResponse?
    var stubbedError: Error?

    // MARK: - Call Tracking
    private(set) var sendCallCount = 0
    private(set) var lastRequest: URLRequest?

    // MARK: - Convenience Stubbing

    /// Stub a successful JSON response
    func stubSuccess<T: Encodable>(_ value: T, statusCode: Int = 200) {
        let encoder = JSONEncoder()
        stubbedData = try? encoder.encode(value)
        stubbedResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )
        stubbedError = nil
    }

    /// Stub an error response
    func stubError(_ error: Error) {
        stubbedData = nil
        stubbedResponse = nil
        stubbedError = error
    }

    /// Stub an HTTP error response
    func stubHTTPError(statusCode: Int, message: String = "Error") {
        stubbedData = message.data(using: .utf8)
        stubbedResponse = HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )
        stubbedError = nil
    }

    // MARK: - NetworkTransport
    @discardableResult
    func send(_ request: URLRequest, callback: @escaping (sending Response) -> Void) -> CancellableObject {
        sendCallCount += 1
        lastRequest = request

        let response = Response(stubbedData, stubbedResponse, stubbedError)
        callback(response)

        return MockCancellable()
    }

    func send(_ request: URLRequest) async -> Response {
        sendCallCount += 1
        lastRequest = request
        return Response(stubbedData, stubbedResponse, stubbedError)
    }

    // MARK: - Reset
    func reset() {
        stubbedData = nil
        stubbedResponse = nil
        stubbedError = nil
        sendCallCount = 0
        lastRequest = nil
    }
}
