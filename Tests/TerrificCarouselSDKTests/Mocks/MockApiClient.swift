//
//  MockApiClient.swift
//  TerrificCarouselSDKTests
//

import Foundation
import HTTPClient
@testable import TerrificCarouselSDK

// MARK: - MockApiClient
/// Mock implementation of ApiClient for testing services
final class MockApiClient: ApiClient {

    // MARK: - Stubbed Response
    var stubbedResponse: Any?
    var stubbedError: Error?

    // MARK: - Call Tracking
    private(set) var sendCallCount = 0
    private(set) var lastRequest: (any Request)?

    // Captured request details for verification
    private(set) var lastPath: String?
    private(set) var lastMethod: HTTPMethod?
    private(set) var lastQuery: Query?
    private(set) var lastBody: Encodable?
    private(set) var lastHeaders: Headers?

    // MARK: - ApiClient
    func send<T: Request>(_ request: T) async throws -> T.Response? {
        sendCallCount += 1
        lastRequest = request
        lastPath = request.path
        lastMethod = request.method
        lastQuery = request.query
        lastBody = request.body
        lastHeaders = request.headers

        if let error = stubbedError {
            throw error
        }

        return stubbedResponse as? T.Response
    }

    // MARK: - Reset
    func reset() {
        stubbedResponse = nil
        stubbedError = nil
        sendCallCount = 0
        lastRequest = nil
        lastPath = nil
        lastMethod = nil
        lastQuery = nil
        lastBody = nil
        lastHeaders = nil
    }
}
