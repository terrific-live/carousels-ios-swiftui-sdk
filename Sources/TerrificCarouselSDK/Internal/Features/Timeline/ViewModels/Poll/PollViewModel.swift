//
//  PollViewModel.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 18.02.2026.
//

import Combine
import SwiftUI

// MARK: - Analytic Delegate Protocol
@MainActor
protocol PollViewModelAnalyticDelegate: AnyObject {
    /// Called when user successfully votes on a poll
    func pollViewModel(
        _ viewModel: PollViewModel,
        didVoteForAssetId assetId: String,
        pollId: String,
        pollAnswer: String,
        questionId: String
    )
}

// MARK: - PollViewModel
@MainActor
final class PollViewModel: ObservableObject {

    // MARK: - Published State (Interface)
    @Published
    private(set) var pollData: PollData
    @Published
    private(set) var selectedOptionIndex: Int?
    @Published
    private(set) var isAnswered: Bool
    @Published
    private(set) var isSubmitting: Bool = false
    @Published
    private(set) var error: String?

    // MARK: - Context
    let assetId: String

    // MARK: - Dependencies
    private let pollService: PollService?
    private let answerStorage: PollAnswerStorage?

    // MARK: - Analytic Delegate
    weak var analyticDelegate: PollViewModelAnalyticDelegate?

    // MARK: - Init
    init(
        assetId: String,
        pollData: PollData,
        pollService: PollService? = nil,
        answerStorage: PollAnswerStorage? = nil,
        isAnswered: Bool = false,
        selectedOptionIndex: Int? = nil
    ) {
        self.assetId = assetId
        self.pollData = pollData
        self.pollService = pollService
        self.answerStorage = answerStorage
        self.isAnswered = isAnswered
        self.selectedOptionIndex = selectedOptionIndex
    }

    // MARK: - Presentation Logic
    func percentage(for option: PollOptionData) -> Int {
        guard pollData.totalVotes > 0 else { return 0 }
        return Int(round(Double(option.numberOfVotes) / Double(pollData.totalVotes) * 100))
    }

    func percentageFraction(for option: PollOptionData) -> Double {
        guard pollData.totalVotes > 0 else { return 0 }
        return Double(option.numberOfVotes) / Double(pollData.totalVotes)
    }
}

// MARK: - Actions
extension PollViewModel {
    func handleSelectOption(_ index: Int) {
        // Prevent submitting while already submitting
        guard !isSubmitting else { return }
        // Skip if tapping on the same option
        guard selectedOptionIndex != index else { return }
        guard let selectedOption = pollData.options.first(where: { $0.id == index }) else { return }

        selectedOptionIndex = index
        error = nil

        Task {
            await submitVote(optionText: selectedOption.text)
        }
    }

    private func submitVote(optionText: String) async {
        isSubmitting = true

        do {
            if let pollService = pollService {
                // Submit to API and get updated results
                let updatedOptions = try await pollService.vote(
                    pollId: pollData.id,
                    questionId: pollData.questionId,
                    vote: optionText
                )

                // Update poll data with server response
                pollData = PollData(
                    id: pollData.id,
                    questionId: pollData.questionId,
                    question: pollData.question,
                    options: updatedOptions.enumerated().map { index, dto in
                        PollOptionData(from: dto, index: index)
                    }
                )
            } else {
                // Fallback: optimistic local update (for previews/testing)
                updateLocalVote()
            }

            // Save answer locally
            saveAnswerLocally(optionText: optionText)

            // Notify analytic delegate
            analyticDelegate?.pollViewModel(
                self,
                didVoteForAssetId: assetId,
                pollId: pollData.id,
                pollAnswer: optionText,
                questionId: pollData.questionId
            )

            withAnimation(.easeInOut(duration: 0.3)) {
                isAnswered = true
            }
        } catch {
            self.error = error.localizedDescription
            selectedOptionIndex = nil
        }

        isSubmitting = false
    }

    private func saveAnswerLocally(optionText: String) {
        guard let selectedIndex = selectedOptionIndex else { return }

        let answer = PollAnswer(
            pollId: pollData.id,
            selectedOptionIndex: selectedIndex,
            selectedOptionText: optionText,
            answeredAt: Date()
        )
        answerStorage?.saveAnswer(answer)
    }

    private func updateLocalVote() {
        guard let selectedIndex = selectedOptionIndex else { return }

        let updatedOptions = pollData.options.map { option in
            if option.id == selectedIndex {
                return PollOptionData(
                    id: option.id,
                    text: option.text,
                    numberOfVotes: option.numberOfVotes + 1
                )
            }
            return option
        }

        pollData = PollData(
            id: pollData.id,
            questionId: pollData.questionId,
            question: pollData.question,
            options: updatedOptions
        )
    }
}
