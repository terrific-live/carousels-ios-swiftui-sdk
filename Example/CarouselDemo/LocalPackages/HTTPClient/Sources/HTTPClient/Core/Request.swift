import Foundation

public typealias Query = [String: Any?]
public typealias EndpointPath = String

public protocol DataRequest: Request {}

/**
 Structure that holds an empty `Response` object.

 `Void` can't be conformed to `Decodable`, so we're somehow forced to make this empty structure for
 requests that don't expect any response in return.
 */
public struct EmptyResponse: Decodable {
    public init() {}
}

/// Request protocol
public protocol Request {
    associatedtype Response: Decodable = EmptyResponse

    /// The HTTP Method of the request. Default: `.get`.
    var method: HTTPMethod { get }

    /// Additional headers for the request. Default: `nil`.
    var headers: Headers? { get }

    /// Request Body type. Default `nil`.
    ///
    /// - Important: !!! Make sure to use `Encodable` as a property type.
    /// It's technically possible to override type with any other encodable.
    /// However it will result in default value being inferred by methods
    /// consuming this parameter.
    ///
    /// ```Swift
    /// struct Body: Encodable {}
    ///
    /// // DO:
    /// struct MyRequest: Request {
    ///     // Overrides default value
    ///     var body: Encodable? { Body() }
    /// // DON'T
    /// struct MyRequest: Request {
    ///     // Uses default value from extension
    ///     var body: Body? { Body() }
    /// ```
    var body: Encodable? { get }

    /// Additional query items. Default `nil`
    var query: Query? { get }

    /// Path to resource endpoint
    var path: EndpointPath? { get }
}

public extension Request {
    var method: HTTPMethod { .get }
    var headers: Headers? { nil }
    var query: Query? { nil }
    var path: String? { nil }
    var body: Encodable? { nil }
}

public struct AnyEncodable: Encodable {
    private let encodable: Encodable

    public init(_ encodable: Encodable) {
        self.encodable = encodable
    }

    public func encode(to encoder: Encoder) throws {
        try encodable.encode(to: encoder)
    }
}
