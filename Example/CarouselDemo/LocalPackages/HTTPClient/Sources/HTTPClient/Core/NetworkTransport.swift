import Foundation
import protocol Combine.Cancellable

public typealias CancellableObject = AnyObject & Cancellable

public protocol NetworkTransport: AnyObject {
    @discardableResult
    func send(_ request: URLRequest, callback: @escaping (sending Response) -> Void) -> CancellableObject
}

public extension NetworkTransport {
    func send(_ request: URLRequest) async -> Response {
        let response = await withUnsafeContinuation { continuation in
            send(request, callback: continuation.resume(returning:))
        }
        return response
    }
}

public final class DefaultNetworkTransport: NetworkTransport {
    public let session: URLSession

    public init(_ configuration: URLSessionConfiguration = .default) {
        self.session = URLSession(configuration: configuration)
    }

    @discardableResult
    public func send(_ request: URLRequest, callback: @escaping (sending Response) -> Void) -> CancellableObject {
        let task = session.dataTask(with: request) { data, response, error in
            let response = Response(data, response, error)
            callback(response)
        }
        task.resume()
        return task
    }

    public func send(_ request: URLRequest) async -> Response {
        do {
            let (data, urlResponse) = try await session.data(for: request)
            return Response(data, urlResponse, nil)
        } catch {
            return Response(nil, nil, error)
        }
    }
}

extension URLSessionDataTask: @retroactive Cancellable {}
