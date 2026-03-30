import Foundation

public struct Response {
    public var urlResponse: URLResponse?
    public var data: Data?
    public var error: Error?

    public init(_ data: Data? = nil, _ response: URLResponse? = nil, _ error: Error? = nil) {
        urlResponse = response
        self.data = data
        self.error = error
    }
}

public extension Response {
    func resolved() throws -> URLResponseSuccess {
        if let error = error { throw error }
        return (data, urlResponse)
    }
}

public typealias URLResponseSuccess = (Data?, URLResponse?)
