import Foundation

public protocol ApiClient {
    func send<T: Request>(_ request: T) async throws -> T.Response?
}

public final class Client: ApiClient {
    public private(set) var interceptor = Interceptor()
    public var transport: NetworkTransport

    var requestAdapter: RequestAdapter
    var responseAdapter: ResponseAdapter

    public func send<T: Request>(_ request: T) async throws -> T.Response? {
        var urlRequest = try await requestAdapter.transform(request)
        try await interceptor.applyRequest(&urlRequest)
        var response = await transport.send(urlRequest)
        try await interceptor.applyResponse(&response, for: &urlRequest, in: transport)
        let decoded: T.Response? = try await responseAdapter.transform(response, for: request)

        return decoded
    }

    public init(
        transport: NetworkTransport,
        requestAdapter: RequestAdapter,
        responseAdapter: ResponseAdapter
    ) {
        self.transport = transport
        self.requestAdapter = requestAdapter
        self.responseAdapter = responseAdapter
    }
}

extension Client {
    /// Initialise client with `JSONResponseAdapter`, `DefaultRequestAdapter` and `DefaultNetworkTransport`
    public convenience init(base urlString: String, version: String? = nil) {
        let url = URL(string: urlString)
        assert(url != nil, "Invalid URL")

        let requestAdapter = DefaultRequestAdapter(base: url, version: version)
        let responseAdapter = JSONResponseAdapter()
        self.init(requestAdapter: requestAdapter, responseAdapter: responseAdapter)
    }

    /// Initialise client with `DefaultNetworkTransport` and provided request and response adapters
    public convenience init(requestAdapter: RequestAdapter, responseAdapter: ResponseAdapter) {
        self.init(
            transport: DefaultNetworkTransport(),
            requestAdapter: requestAdapter,
            responseAdapter: responseAdapter
        )
    }

    /// Initialize client with custom `NetworkTransport`and default `DefaultRequestAdapter`
    public convenience init(base urlString: String, version: String?, transport: NetworkTransport) {
        let url = URL(string: urlString)
        assert(url != nil, "Invalid URL")

        let requestAdapter = DefaultRequestAdapter(base: url, version: version)
        let responseAdapter = JSONResponseAdapter()

        self.init(
            transport: transport,
            requestAdapter: requestAdapter,
            responseAdapter: responseAdapter
        )
    }
}

extension Client {
    public enum Error: Swift.Error {
        case invalidURL
        case emptyBody
    }
}
