import Foundation

/// This actor represents stack of `RequestInterceptor` and `ResponseInterceptor` which is called
/// in a reverse order.
///
/// It is technically possible to combine both types of interceptors in a single entity. However due
/// to the implementation detail (and to keep somewhat flexibility in call order) there is no general
/// method to add such combined interceptor.
///
/// The combined interceptor can be added as:
/// ```Swift
/// let retryInterceptor = RequestAndResponseInterceptor()
/// let stack = Interceptor()
/// stack.push(RequestOnlyInterceptor())
/// stack.push(retryInterceptor as RequestInterceptor) // Will be executed before `RequestOnlyInterceptor`
/// stack.push(ResponseOnlyInterceptor())
/// stack.push(retryInterceptor as ResponseInterceptor) // Will be executed before `ResponseOnlyInterceptor`
/// ```
public class Interceptor {
    private(set) internal var current: Responder?

    public init() {
        current = nil
    }

    /// Pushes interceptor into the stack
    ///
    /// - parameter interceptor: `RequestInterceptor` instance
    @discardableResult
    public func push(_ interceptor: RequestInterceptor) -> Self {
        current = InterceptorWrapper(next: current, wrapperValue: interceptor)
        return self
    }

    /// Pushes interceptor into the stack
    ///
    /// - parameter interceptor: `ResponseInterceptor` instance
    @discardableResult
    public func push(_ interceptor: ResponseInterceptor) -> Self {
        current = InterceptorWrapper(next: current, wrapperValue: interceptor)
        return self
    }

    public func applyRequest(_ request: inout URLRequest) async throws {
        try await test { (interceptor: InterceptorWrapper<RequestInterceptor>) in
            try await interceptor.wrapperValue.intercept(&request)
        }
    }

    public func applyResponse(
        _ response: inout Response,
        for request: inout URLRequest,
        in transport: NetworkTransport
    ) async throws {
        try await test { (interceptor: InterceptorWrapper<ResponseInterceptor>) in
            try await interceptor.wrapperValue.intercept(
                &response,
                for: &request,
                in: transport
            )
        }
    }

    /// Drops the interceptors list.
    public func clean() {
        current = nil
    }

    private func test<Object>(execute: (Object) async throws -> Void) async rethrows {
        var last = current
        repeat {
            if let interceptor = last as? Object {
                try await execute(interceptor)
            }
            last = last?.next

        } while last != nil
    }
}
