import Foundation

enum ResponseType {
    case succeed, notModified
    case badRequest, unauthorized, upgradeRequired, forbidden, notAcceptable, gone
    case canceled, unprocessable, notFound, unknownError, clientTimeOut, notConnected
    case rateLimitExceed
    case conflict, internalError, badGateway, serviceUnavailable, requestTimeOut, gatewayTimeOut

    /// The response type for a given HTTP code.
    ///
    /// - parameter code: The HTTP code.
    ///
    /// - returns: The response code meaning.
    init(fromCode code: Int) {
        if 200..<300 ~= code {
            self = .succeed
            return
        }

        self = Self.errorMap[code] ?? .unknownError
    }
}

extension ResponseType: Equatable {}

extension ResponseType {
    static let goodResponses: [Self] = [
        .succeed,
        .notModified,
        .canceled
    ]

    static var clientErrors: [Self] = [
        .badRequest,
        .unauthorized,
        .forbidden,
        .notFound,
        .notAcceptable,
        .requestTimeOut,
        .conflict,
        .gone,
        .unprocessable,
        .upgradeRequired,
        .rateLimitExceed,
        .clientTimeOut,
        .notConnected
    ]

    static var serverErrors: [Self] = [
        .internalError,
        .badGateway,
        .serviceUnavailable,
        .gatewayTimeOut
    ]
}

private extension ResponseType {
    static let errorMap: [Int: ResponseType] = [
        ErrorCode.notModified: .notModified,
        ErrorCode.badRequest: .badRequest,
        ErrorCode.unauthorized: .unauthorized,
        ErrorCode.forbidden: .forbidden,
        ErrorCode.notFound: .notFound,
        ErrorCode.notAcceptable: .notAcceptable,
        ErrorCode.requestTimeOut: .requestTimeOut,
        ErrorCode.conflict: .conflict,
        ErrorCode.gone: .gone,
        ErrorCode.unprocessable: .unprocessable,
        ErrorCode.upgradeRequired: .upgradeRequired,
        ErrorCode.rateLimitExceed: .rateLimitExceed,
        ErrorCode.internalError: .internalError,
        ErrorCode.badGateway: .badGateway,
        ErrorCode.serviceUnavailable: .serviceUnavailable,
        ErrorCode.gatewayTimeOut: .gatewayTimeOut,
        NSURLErrorCancelled: .canceled,
        NSURLErrorTimedOut: .clientTimeOut,
        NSURLErrorNotConnectedToInternet: .notConnected
    ]
}
