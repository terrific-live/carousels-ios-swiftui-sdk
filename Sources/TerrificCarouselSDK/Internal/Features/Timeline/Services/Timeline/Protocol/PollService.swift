//
//  PollService.swift
//  CarouselDemo
//

import Foundation

// MARK: - PollService Protocol
protocol PollService {
    /// Submits a vote for a poll option.
    /// - Parameters:
    ///   - pollId: The poll identifier
    ///   - questionId: The question identifier within the poll
    ///   - vote: The text of the selected option
    /// - Returns: Updated poll options with vote counts
    func vote(
        pollId: String,
        questionId: String,
        vote: String
    ) async throws -> [PollOptionDTO]
}
