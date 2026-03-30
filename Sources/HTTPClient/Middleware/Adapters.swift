import Foundation

public protocol RequestAdapter {
    func transform<T: Request>(_ request: T) async throws -> URLRequest
}

public protocol ResponseAdapter {
    func transform<T: Request>(_ response: Response, for request: T) async throws -> T.Response?
}

public actor DefaultRequestAdapter: RequestAdapter {
    let base: URL?
    let version: String?
    static var encoder = JSONEncoder()

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
            urlRequest.httpBody = try Self.encoder.encode(body)
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

// Simple Response adapter with JSON decode
public actor JSONResponseAdapter: ResponseAdapter {
    /// Work around decoding Empty JSON reponses
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

    public init() {}

    public func transform<T: Request>(_ response: Response, for request: T) async throws -> T.Response? {
        if let error = response.error {
            throw ApiError.transport(error)
        }

        guard let data = response.data else { return nil }
        let response = try CustomJSONDecoder().decode(T.Response.self, from: data)
        return response
    }
}

extension JSONResponseAdapter {
    public enum Error: Swift.Error {
        case emptyBody
        case emptyResponse
    }
}
