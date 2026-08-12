//
//  MockPollAnswerStorage.swift
//  TerrificCarouselSDKTests
//

@testable import TerrificCarouselSDK

@MainActor
final class MockPollAnswerStorage: PollAnswerStorage {
    private var answers: [String: PollAnswer] = [:]

    func getAnswer(for pollId: String) -> PollAnswer? {
        answers[pollId]
    }

    func saveAnswer(_ answer: PollAnswer) {
        answers[answer.pollId] = answer
    }

    func removeAnswer(for pollId: String) {
        answers.removeValue(forKey: pollId)
    }

    func clearAll() {
        answers.removeAll()
    }
}
