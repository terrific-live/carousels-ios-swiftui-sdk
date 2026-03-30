import Foundation

public struct HeaderInterceptor: RequestInterceptor {
    public typealias Header = (key: String, value: String)
    public typealias Injector = () async throws -> Header

    public var injector: Injector

    public init(_ injector: @escaping Injector) {
        self.injector = injector
    }

    public func intercept(_ request: inout URLRequest) async throws {
        let header: Header = try await injector()
        request.addValue(header.value, forHTTPHeaderField: header.key)
    }
}
