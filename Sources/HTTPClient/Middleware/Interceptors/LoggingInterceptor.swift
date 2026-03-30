//
//  LoggingInterceptor.swift
//  HTTPClient
//

import Foundation

// MARK: - LoggingInterceptor
/// Interceptor that logs HTTP requests and responses
public final class LoggingInterceptor: RequestInterceptor, ResponseInterceptor {

    private let isRequestLoggingEnabled: Bool
    private let isResponseLoggingEnabled: Bool

    public init(isRequestLoggingEnabled: Bool = true, isResponseLoggingEnabled: Bool = true) {
        self.isRequestLoggingEnabled = isRequestLoggingEnabled
        self.isResponseLoggingEnabled = isResponseLoggingEnabled
    }

    // MARK: - RequestInterceptor
    public func intercept(_ request: inout URLRequest) async throws {
        guard isRequestLoggingEnabled else { return }

        #if DEBUG
        let method = request.httpMethod ?? "GET"
        let url = request.url?.absoluteString ?? "unknown"
        debugPrint("🌐 [\(method)] \(url)")

        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            debugPrint("📋 Headers: \(headers)")
        }

        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            debugPrint("📦 Body: \(bodyString.prefix(500))")
        }
        #endif
    }

    // MARK: - ResponseInterceptor
    public func intercept(
        _ response: inout Response,
        for request: inout URLRequest,
        in transport: NetworkTransport
    ) async throws {
        guard isResponseLoggingEnabled else { return }

        #if DEBUG
        let url = request.url?.absoluteString ?? "unknown"
        let statusCode = (response.urlResponse as? HTTPURLResponse)?.statusCode ?? 0
        let dataSize = response.data?.count ?? 0

        debugPrint("📥 [\(statusCode)] \(url) (\(dataSize) bytes)")

        if let error = response.error {
            debugPrint("❌ Error: \(error.localizedDescription)")
        }
        #endif
    }
}
