//
//  TimelineClients.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 26.02.2026.
//

import Foundation
import HTTPClient

// MARK: - TimelineClient
/// Single client for Timeline API with interceptor pipeline.
/// Handles both feed and detail endpoints - differentiation happens at Request level.
final class TimelineClient {
    let client: Client

    private init(client: Client) {
        self.client = client
    }

    // MARK: - Factory
    static func live(configuration: APIConfiguration) -> TimelineClient {
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

        return TimelineClient(client: client)
    }

    // MARK: - Preview/Testing
    static var fake: TimelineClient {
        let client = Client(base: "http://127.0.0.1")
        return TimelineClient(client: client)
    }
}
