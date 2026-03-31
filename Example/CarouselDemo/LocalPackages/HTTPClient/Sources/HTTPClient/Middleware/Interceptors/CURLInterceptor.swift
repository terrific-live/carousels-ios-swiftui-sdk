import Foundation
import OSLog

/// Interceptor that logs HTTP requests as cURL commands and responses with formatted JSON
public final class CURLInterceptor: RequestInterceptor, ResponseInterceptor {

    private let logger = Logger(subsystem: "HTTPClient", category: "CURL")

    public init() {}

    // MARK: - RequestInterceptor
    public func intercept(_ request: inout URLRequest) async throws {
        guard HTTPClientLogger.isEnabled else { return }

        let method = request.httpMethod ?? "GET"
        let url = request.url?.absoluteString ?? "unknown"
        let curl = request.curlString

        // OSLog for short summary (persisted for diagnostics)
        logger.info("🔷 [\(method, privacy: .public)] \(url, privacy: .public)")

        // debugPrint for full cURL (Xcode console, not truncated)
        #if DEBUG
        print("🔷 cURL:\n\(curl)\n")
        #endif
    }

    // MARK: - ResponseInterceptor
    public func intercept(
        _ response: inout Response,
        for request: inout URLRequest,
        in transport: NetworkTransport
    ) async throws {
        guard HTTPClientLogger.isEnabled else { return }

        let url = request.url?.absoluteString ?? "unknown"
        let statusCode = (response.urlResponse as? HTTPURLResponse)?.statusCode ?? 0
        let isSuccess = (200..<300).contains(statusCode)

        // OSLog for summary (persisted)
        if isSuccess {
            logger.info("✅ [\(statusCode, privacy: .public)] \(url, privacy: .public)")
        } else {
            logger.error("❌ [\(statusCode, privacy: .public)] \(url, privacy: .public)")
        }

        // debugPrint for full body (Xcode console, not truncated)
        #if DEBUG
        if let bodyData = response.data {
            if let jsonObject = try? JSONSerialization.jsonObject(with: bodyData, options: []),
               let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                print("📄 Body:\n\(prettyString)\n")
            } else if let bodyString = String(data: bodyData, encoding: .utf8), !bodyString.isEmpty {
                print("📄 Body: \(bodyString)\n")
            }
        }
        #endif

        if let error = response.error {
            logger.error("⚠️ Error: \(error.localizedDescription, privacy: .public)")
        }
    }
}

private extension URLRequest {
    /**
     Returns a cURL command representation of this URL request.
     */
    var curlString: String {
        guard let url = url else { return "" }
        var baseCommand = #"curl "\#(url.absoluteString)""#

        if httpMethod == "HEAD" {
            baseCommand += " --head"
        }

        var command = [baseCommand]

        if let method = httpMethod, method != "GET" && method != "HEAD" {
            command.append("-X \(method)")
        }

        if let headers = allHTTPHeaderFields {
            for (key, value) in headers where key != "Cookie" {
                if key == "Authorization" {
                    command.append("-H '\(key): ***'")
                } else {
                    command.append("-H '\(key): \(value)'")
                }
            }
        }

        if let data = httpBody {
            let body = String(decoding: data, as: UTF8.self)
            command.append("-d '\(body)'")
        }

        return command.joined(separator: " \\\n\t")
    }
}
