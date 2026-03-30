//
//  PollAnswerStorage.swift
//  CarouselDemo
//

import Foundation

// MARK: - PollAnswer
struct PollAnswer: Codable, Equatable {
    let pollId: String
    let selectedOptionIndex: Int
    let selectedOptionText: String
    let answeredAt: Date
}

// MARK: - PollAnswerStorage Protocol
/// All implementations are guaranteed to run on MainActor for thread safety.
@MainActor
protocol PollAnswerStorage {
    /// Retrieves the saved answer for a poll.
    func getAnswer(for pollId: String) -> PollAnswer?

    /// Saves an answer for a poll.
    func saveAnswer(_ answer: PollAnswer)

    /// Removes the answer for a poll.
    func removeAnswer(for pollId: String)

    /// Clears all saved answers.
    func clearAll()
}

// MARK: - UserDefaultsPollAnswerStorage
@MainActor
final class UserDefaultsPollAnswerStorage: PollAnswerStorage {

    // MARK: - Constants
    private enum Keys {
        static let pollAnswersKey = "com.carouseldemo.pollAnswers"
    }

    // MARK: - Dependencies
    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Init
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - PollAnswerStorage
    func getAnswer(for pollId: String) -> PollAnswer? {
        let answers = loadAllAnswers()
        return answers[pollId]
    }

    func saveAnswer(_ answer: PollAnswer) {
        var answers = loadAllAnswers()
        answers[answer.pollId] = answer
        saveAllAnswers(answers)
    }

    func removeAnswer(for pollId: String) {
        var answers = loadAllAnswers()
        answers.removeValue(forKey: pollId)
        saveAllAnswers(answers)
    }

    func clearAll() {
        userDefaults.removeObject(forKey: Keys.pollAnswersKey)
    }

    // MARK: - Private
    private func loadAllAnswers() -> [String: PollAnswer] {
        guard let data = userDefaults.data(forKey: Keys.pollAnswersKey),
              let answers = try? decoder.decode([String: PollAnswer].self, from: data) else {
            return [:]
        }
        return answers
    }

    private func saveAllAnswers(_ answers: [String: PollAnswer]) {
        guard let data = try? encoder.encode(answers) else { return }
        userDefaults.set(data, forKey: Keys.pollAnswersKey)
    }
}

// MARK: - Mock Implementation
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
