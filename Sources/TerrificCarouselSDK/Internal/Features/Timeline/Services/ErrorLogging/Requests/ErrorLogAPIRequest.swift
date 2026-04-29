//
//  ErrorLogAPIRequest.swift
//  TerrificCarouselSDK
//

import Foundation
import HTTPClient

// MARK: - ErrorLogEntry
struct ErrorLogEntry: Encodable {
    let message: String
    let severity: String
    let project: String
    let route: String
    let timestamp: String
    let metadata: [String: String]?
}

// MARK: - ErrorLogRequestBody
struct ErrorLogRequestBody: Encodable {
    let userId: String
    let entries: [ErrorLogEntry]
}

// MARK: - ErrorLogAPIRequest
struct ErrorLogAPIRequest: Request {
    typealias Response = TextResponse

    let requestBody: ErrorLogRequestBody

    var method: HTTPMethod { .post }

    var headers: Headers? {
        [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }

    var path: EndpointPath? {
        "/logFrontEnd"
    }

    var body: Encodable? {
        requestBody
    }
}
