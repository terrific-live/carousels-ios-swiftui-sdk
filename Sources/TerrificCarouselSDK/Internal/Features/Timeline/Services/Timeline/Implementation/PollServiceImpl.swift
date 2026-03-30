//
//  PollServiceImpl.swift
//  CarouselDemo
//

import Foundation
import HTTPClient

// MARK: - PollServiceImpl
/// Real implementation of PollService
/// Uses Client with interceptor pipeline
struct PollServiceImpl: PollService {

    // MARK: - Dependencies
    private let client: Client
    private let configuration: APIConfiguration
    private let terrificUserId: String

    // MARK: - Init
    init(
        client: Client,
        configuration: APIConfiguration,
        terrificUserId: String
    ) {
        self.client = client
        self.configuration = configuration
        self.terrificUserId = terrificUserId
    }

    // MARK: - PollService
    func vote(
        pollId: String,
        questionId: String,
        vote: String
    ) async throws -> [PollOptionDTO] {
        let request = PollVoteAPIRequest(
            storeId: configuration.storeId,
            pollId: pollId,
            questionId: questionId,
            userId: terrificUserId,
            vote: vote
        )

        let response = try await client.send(request)
        return response ?? []
    }
}
