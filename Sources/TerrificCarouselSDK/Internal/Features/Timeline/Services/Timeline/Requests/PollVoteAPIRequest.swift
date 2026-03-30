//
//  PollVoteAPIRequest.swift
//  CarouselDemo
//

import Foundation
import HTTPClient

// MARK: - PollVoteRequestBody
struct PollVoteRequestBody: Encodable {
    let questionId: String
    let userId: String
    let vote: String
}

// MARK: - PollVoteAPIRequest
/// Request for voting on a poll
/// Endpoint: POST /api/v1/stores/{storeId}/poll/{pollId}
struct PollVoteAPIRequest: Request {
    typealias Response = [PollOptionDTO]

    let storeId: String
    let pollId: String
    let questionId: String
    let userId: String
    let vote: String

    var method: HTTPMethod { .post }

    var headers: Headers? {
        ["Content-Type": "application/json"]
    }

    var path: EndpointPath? {
        "/api/v1/stores/\(storeId)/poll/\(pollId)"
    }

    var body: Encodable? {
        PollVoteRequestBody(
            questionId: questionId,
            userId: userId,
            vote: vote
        )
    }
}
