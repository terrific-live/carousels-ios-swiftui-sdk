//
//  ErrorLoggingClient.swift
//  TerrificCarouselSDK
//

import Foundation
import HTTPClient

// MARK: - ErrorLoggingClient
struct ErrorLoggingClient {
    let client: Client
}

// MARK: - Live Implementation
extension ErrorLoggingClient {
    static func live(configuration: ErrorLoggingConfiguration) -> ErrorLoggingClient {
        let baseURL = configuration.baseURL?.absoluteString ?? ""

        let client = Client(base: baseURL, version: nil)

        // Configure interceptors for debugging
        let cURLInterceptor = CURLInterceptor()
        client.interceptor.push(cURLInterceptor as RequestInterceptor)
        client.interceptor.push(cURLInterceptor as ResponseInterceptor)

        return ErrorLoggingClient(client: client)
    }
}
