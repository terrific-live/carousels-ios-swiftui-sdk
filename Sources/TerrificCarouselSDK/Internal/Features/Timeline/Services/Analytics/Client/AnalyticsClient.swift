//
//  AnalyticsClient.swift
//  CarouselDemo
//

import Foundation
import HTTPClient

// MARK: - AnalyticsClient
/// Client for Analytics API with interceptor pipeline.
final class AnalyticsClient {
    let client: Client

    private init(client: Client) {
        self.client = client
    }

    // MARK: - Factory
    static func live(configuration: AnalyticsConfiguration) -> AnalyticsClient {
        let baseURL = configuration.baseURL.absoluteString

        // Create client
        let client = Client(base: baseURL, version: nil)

        // Configure interceptors
        let cURLInterceptor = CURLInterceptor()
        let httpErrorInterceptor = HTTPResponseErrorInterceptor()

        // Apply interceptors (LIFO order - first pushed executes last)
        // Response execution order: CURL (logs) -> HTTPError (throws on error)
        client.interceptor.push(httpErrorInterceptor as ResponseInterceptor)
        client.interceptor.push(cURLInterceptor as RequestInterceptor)
        client.interceptor.push(cURLInterceptor as ResponseInterceptor)

        return AnalyticsClient(client: client)
    }

    // MARK: - Preview/Testing
    static var fake: AnalyticsClient {
        let client = Client(base: "http://127.0.0.1")
        return AnalyticsClient(client: client)
    }
}
