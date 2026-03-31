//
//  HTTPResponseErrorInterceptor.swift
//  HTTPClient
//

import Foundation

public struct HTTPResponseErrorInterceptor: ResponseInterceptor {
    public init() {}

    public func intercept(
        _ response: inout Response,
        for request: inout URLRequest,
        in transport: NetworkTransport
    ) async throws {
        guard let httpResponse = response.urlResponse as? HTTPURLResponse else {
            return
        }

        let responseType = ResponseType(fromCode: httpResponse.statusCode)
        switch responseType {
        case ResponseType.goodResponses:
            return
        default:
            let responseBody = response.data.map { String(decoding: $0, as: UTF8.self) }
            throw HTTPError(
                statusCode: httpResponse.statusCode,
                responseBody: responseBody,
                underlyingError: response.error
            )
        }
    }
}

private func ~= <T: Equatable>(array: [T], value: T) -> Bool {
    return array.contains(value)
}
