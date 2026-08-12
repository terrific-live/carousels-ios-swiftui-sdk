import Foundation

public protocol RequestAdapter {
    func transform<T: Request>(_ request: T) async throws -> URLRequest
}

public protocol ResponseAdapter: AnyObject {
    var next: ResponseAdapter? { get set }
    func transform<T: Request>(_ response: Response, for request: T) async throws -> T.Response?
}

extension ResponseAdapter {
    func tryNext<T: Request>(_ response: Response, for request: T) async throws -> T.Response? {
        guard let next else {
            throw ResponseAdapterError.noAdapterCanHandle
        }
        return try await next.transform(response, for: request)
    }
}

public enum ResponseAdapterError: Error {
    case noAdapterCanHandle
}

public actor DefaultRequestAdapter: RequestAdapter {
    let base: URL?
    let version: String?
    private let encoder = JSONEncoder()

    public init(base url: URL?, version: String? = nil) {
        self.base = url
        self.version = version
    }

    public func transform<T: Request>(_ request: T) async throws -> URLRequest {
        guard var base = base else { throw ApiError.encoding(Error.invalidURL) }
        base = version.flatMap(base.appendingPathComponent) ?? base
        let endpoint = request.path.flatMap(base.appendingPathComponent) ?? base
        let url = request.query.flatMap(endpoint.with(query:)) ?? endpoint
        var urlRequest = URLRequest(url: url)

        if let body = request.body {
            urlRequest.httpBody = try encoder.encode(body)
        }

        request.headers?.forEach {
            urlRequest.setValue($1, forHTTPHeaderField: $0)
        }
        urlRequest.httpMethod = request.method.rawValue.uppercased()

        return urlRequest
    }
}

extension DefaultRequestAdapter {
    public enum Error: Swift.Error {
        case invalidURL
    }
}

// MARK: - TextResponseAdapter
/// Handles TextResponse type by converting data to string
public final class TextResponseAdapter: ResponseAdapter {
    public var next: ResponseAdapter?

    public init(next: ResponseAdapter? = nil) {
        self.next = next
    }

    public func transform<T: Request>(_ response: Response, for request: T) async throws -> T.Response? {
        if let error = response.error {
            throw ApiError.transport(error)
        }

        // Only handle TextResponse type
        guard T.Response.self == TextResponse.self else {
            HTTPClientLogger.logAdapterFallback(
                adapter: "TextResponseAdapter",
                responseType: String(describing: T.Response.self),
                error: nil
            )
            return try await tryNext(response, for: request)
        }

        let text: String
        if let data = response.data {
            text = String(data: data, encoding: .utf8) ?? ""
        } else {
            text = ""
        }
        return TextResponse(text: text) as? T.Response
    }
}

// MARK: - JSONResponseAdapter
/// Handles JSON decoding, passes to next adapter on failure
public final class JSONResponseAdapter: ResponseAdapter {
    public var next: ResponseAdapter?

    /// Work around decoding Empty JSON responses
    final class CustomJSONDecoder: JSONDecoder, @unchecked Sendable {
        override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
            switch type {
            case is EmptyResponse.Type:
                // swiftlint:disable:next force_cast
                return try decodeEmpty(from: data) as! T
            default:
                if data.isEmpty { throw ApiError.emptyResponse(Error.emptyResponse) }
                return try super.decode(type, from: data)
            }
        }

        private func decodeEmpty(from data: Data) throws -> EmptyResponse {
            if data.isEmpty { return EmptyResponse() }
            return try super.decode(EmptyResponse.self, from: data)
        }
    }

    public init(next: ResponseAdapter? = nil) {
        self.next = next
    }

    public func transform<T: Request>(_ response: Response, for request: T) async throws -> T.Response? {
        if let error = response.error {
            throw ApiError.transport(error)
        }

        guard let data = response.data else { return nil }

        do {
            let decoded = try CustomJSONDecoder().decode(T.Response.self, from: data)
            return decoded
        } catch {
            HTTPClientLogger.logAdapterFallback(
                adapter: "JSONResponseAdapter",
                responseType: String(describing: T.Response.self),
                error: error,
                dataPreview: String(data: data.prefix(200), encoding: .utf8)
            )
            return try await tryNext(response, for: request)
        }
    }
}

extension JSONResponseAdapter {
    public enum Error: Swift.Error {
        case emptyBody
        case emptyResponse
    }
}
