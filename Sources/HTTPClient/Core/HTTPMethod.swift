import Foundation

public enum HTTPMethod: String {
    /// The `GET` method requests a representation of the specified resource.
    /// Requests using `GET` should only retrieve data.
    case get
    /// The `POST` method submits an entity to the specified resource,
    /// often causing a change in state or side effects on the server.
    case post
    /// The `PUT` method replaces all current representations of the target resource
    /// with the request payload.
    case put
    /// The `HEAD` method asks for a response identical to a `GET` request,
    /// but without the response body.
    case head
    /// The `DELETE` method deletes the specified resource.
    case delete
    /// The `OPTIONS` method describes the communication options for the target resource.
    case options
    /// The `TRACE` method performs a message loop-back test along the path to the target resource.
    case trace
    /// The `PATCH` method applies partial modifications to a resource.
    case patch
    /// The `CONNECT` method establishes a tunnel to the server identified by the target resource.
    case connect
}

extension HTTPMethod: CaseIterable {}

extension HTTPMethod: CustomStringConvertible {
    public var description: String { self.rawValue.uppercased() }
}

extension HTTPMethod {
    /// Idempotent request are likely to complete with the same result,
    /// so sometimes it's safe to cache them.
    /// However, the resulting status code might be different for a
    /// consecutive requests. E.g. `DELETE` might return `404` on a
    /// successive call
    public var isIdempotent: Bool {
        [.get, .head, .put, .delete].contains(self)
    }
}
