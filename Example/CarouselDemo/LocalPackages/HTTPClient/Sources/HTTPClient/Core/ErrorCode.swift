//
//  ErrorCode.swift
//  HTTPClient
//
//  Created by Severyn-Wsevolod on 11.12.2024.
//

enum ErrorCode {
    static let notModified = 304
    static let badRequest = 400
    static let unauthorized = 401
    static let forbidden = 403
    static let notFound = 404
    static let notAcceptable = 406
    static let requestTimeOut = 408
    static let conflict = 409
    static let gone = 410
    static let unprocessable = 422
    static let upgradeRequired = 426
    static let rateLimitExceed = 429
    static let internalError = 500
    static let badGateway = 502
    static let serviceUnavailable = 503
    static let gatewayTimeOut = 504
}
