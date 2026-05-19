//
//  MockPollViewModelAnalyticDelegate.swift
//  TerrificCarouselSDKTests
//

import Foundation
@testable import TerrificCarouselSDK

@MainActor
final class MockPollViewModelAnalyticDelegate: PollViewModelAnalyticDelegate {

    // MARK: - Call Tracking
    struct VoteEvent {
        let assetId: String
        let pollId: String
        let pollAnswer: String
        let questionId: String
    }

    private(set) var voteEvents: [VoteEvent] = []

    // MARK: - PollViewModelAnalyticDelegate
    func pollViewModel(
        _ viewModel: PollViewModel,
        didVoteForAssetId assetId: String,
        pollId: String,
        pollAnswer: String,
        questionId: String
    ) {
        voteEvents.append(VoteEvent(
            assetId: assetId,
            pollId: pollId,
            pollAnswer: pollAnswer,
            questionId: questionId
        ))
    }

    // MARK: - Reset
    func reset() {
        voteEvents.removeAll()
    }
}
