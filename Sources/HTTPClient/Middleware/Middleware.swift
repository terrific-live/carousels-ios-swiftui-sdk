import Foundation

/// Prepares request for execution
public protocol RequestInterceptor {
    func intercept(_ request: inout URLRequest) async throws
}

/// Intercepts responses for specific request.
/// This protocol can be a good entry point for specific error handling
public protocol ResponseInterceptor {
    func intercept(
        _ response: inout Response,
        for request: inout URLRequest,
        in transport: NetworkTransport
    ) async throws
}

protocol Event {
    associatedtype Handler

    func send(to handler: Handler)
}

protocol Responder {
    var next: Responder? { get set }
}

extension Responder {
    func handle<EventType: Event>(_ message: EventType) async {
        await message.send(to: self)
    }
}

extension Event {
    func send(to responder: Responder) async {
        guard let handler: Handler = handlerInChain(startingWith: responder) else {
            fatalError("can't find event \(self) in provided chain")
        }
        send(to: handler)
    }

    private func handlerInChain<Handler>(startingWith responder: Responder) -> Handler? {
        var nextResponder: Responder? = responder
        while let responder = nextResponder {
            if let handler = responder as? Handler {
                return handler
            }
            nextResponder = responder.next
        }
        return nil
    }
}

struct InterceptorWrapper<Type>: Responder {
    var next: Responder?
    let wrapperValue: Type
}
