//
//  File.swift
//

import Foundation
import Combine

extension Client {
    /// - warning: Doesn't support cancellation yet.
    func send<T: Request>(_ request: T) -> AnyPublisher<T.Response?, Swift.Error> {
        Deferred {
            Future { promise in
                Task { [weak self] in
                    guard let self = self else {
                        promise(.failure(CancellationError()))
                        return
                    }
                    do {
                        let response = try await self.send(request)
                        promise(.success(response))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

extension Optional {
    /// Unwraps an optional value, throwing `ApiError.emptyResponse` if the value is `nil`.
    /// - Throws: `ApiError.emptyResponse` if the optional is `nil`.
    /// - Returns: The unwrapped value if the optional is not `nil`.
    func unwrapOrThrow() throws -> Wrapped {
        guard let value = self else {
            throw ApiError.emptyResponse(JSONResponseAdapter.Error.emptyResponse)
        }
        return value
    }
}
