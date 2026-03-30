import Foundation

// MARK: - HTTPError
/// General HTTP error that captures status code and response details
public struct HTTPError: Error, LocalizedError {
    public let statusCode: Int
    public let responseBody: String?
    public let underlyingError: Error?

    public init(statusCode: Int, responseBody: String? = nil, underlyingError: Error? = nil) {
        self.statusCode = statusCode
        self.responseBody = responseBody
        self.underlyingError = underlyingError
    }

    public var errorDescription: String? {
        var description = "HTTP Error \(statusCode)"
        if let body = responseBody, !body.isEmpty {
            description += ": \(body)"
        }
        return description
    }

    /// Whether this is a client error (4xx)
    public var isClientError: Bool {
        (400..<500).contains(statusCode)
    }

    /// Whether this is a server error (5xx)
    public var isServerError: Bool {
        (500..<600).contains(statusCode)
    }

    /// Whether this is a not found error (404)
    public var isNotFound: Bool {
        statusCode == 404
    }

    /// Whether this is an unauthorized error (401)
    public var isUnauthorized: Bool {
        statusCode == 401
    }

    /// Whether this is a forbidden error (403)
    public var isForbidden: Bool {
        statusCode == 403
    }
}

// MARK: - ApiError
public enum ApiError: Error {
    case encoding(_ backing: Error?)
    case decoding(_ backing: Error?)
    case transport(_ backing: Error?)
    case client(_ backing: Error?)
    case serverError([String])
    case notFound(_ backing: Error?)
    case emptyResponse(_ backing: Error?)

    @available(*, deprecated, message: "Prefer to use specific errors instead")
    case unknown
}
