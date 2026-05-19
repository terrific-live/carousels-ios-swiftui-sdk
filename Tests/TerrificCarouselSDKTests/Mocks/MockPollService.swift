//
//  MockPollService.swift
//  TerrificCarouselSDKTests
//

import Foundation
@testable import TerrificCarouselSDK

final class MockPollService: PollService {

    // MARK: - Stubbed Responses
    var stubbedOptions: [PollOptionDTO]?
    var stubbedError: Error?

    // MARK: - Call Tracking
    private(set) var voteCallCount = 0
    private(set) var lastVotePollId: String?
    private(set) var lastVoteQuestionId: String?
    private(set) var lastVoteOption: String?

    // MARK: - PollService
    func vote(
        pollId: String,
        questionId: String,
        vote: String
    ) async throws -> [PollOptionDTO] {
        voteCallCount += 1
        lastVotePollId = pollId
        lastVoteQuestionId = questionId
        lastVoteOption = vote

        if let error = stubbedError {
            throw error
        }

        return stubbedOptions ?? []
    }

    // MARK: - Reset
    func reset() {
        stubbedOptions = nil
        stubbedError = nil
        voteCallCount = 0
        lastVotePollId = nil
        lastVoteQuestionId = nil
        lastVoteOption = nil
    }
}
