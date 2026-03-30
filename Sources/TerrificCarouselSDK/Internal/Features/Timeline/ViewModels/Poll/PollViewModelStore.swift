//
//  PollViewModelStore.swift
//  CarouselDemo

import Foundation

/// Manages PollViewModel instances to ensure persistence during carousel lifetime.
/// Uses asset ID as the key to cache and retrieve PollViewModels.
/// Also handles restoring poll state from local storage.
@MainActor
final class PollViewModelStore {

    // MARK: - Private Storage
    private var viewModels: [String: PollViewModel] = [:]

    // MARK: - Dependencies
    nonisolated(unsafe) private let pollService: PollService?
    nonisolated(unsafe) private let answerStorage: PollAnswerStorage?

    // MARK: - Analytic Delegate (forwarded to PollViewModels)
    weak var analyticDelegate: PollViewModelAnalyticDelegate? {
        didSet {
            // Update delegate on all existing view models
            for viewModel in viewModels.values {
                viewModel.analyticDelegate = analyticDelegate
            }
        }
    }

    // MARK: - Init
    nonisolated init(pollService: PollService? = nil, answerStorage: PollAnswerStorage? = nil) {
        self.pollService = pollService
        self.answerStorage = answerStorage
    }

    // MARK: - Public Interface

    /// Returns existing PollViewModel for the asset or creates a new one if poll data is provided.
    /// Automatically restores answered state from local storage.
    /// - Parameters:
    ///   - assetId: Unique identifier for the asset
    ///   - pollData: Poll data to create a new view model if one doesn't exist
    /// - Returns: PollViewModel if poll data exists, nil otherwise
    func getOrCreate(for assetId: String, pollData: PollData?) -> PollViewModel? {
        // Return existing if available
        if let existing = viewModels[assetId] {
            return existing
        }

        // Create new if poll data is provided
        guard let pollData = pollData else {
            return nil
        }

        // Check for saved answer
        let savedAnswer = answerStorage?.getAnswer(for: pollData.id)
        let isAnswered = savedAnswer != nil
        let selectedOptionIndex = savedAnswer?.selectedOptionIndex

        let viewModel = PollViewModel(
            assetId: assetId,
            pollData: pollData,
            pollService: pollService,
            answerStorage: answerStorage,
            isAnswered: isAnswered,
            selectedOptionIndex: selectedOptionIndex
        )

        // Forward analytics delegate
        viewModel.analyticDelegate = analyticDelegate

        viewModels[assetId] = viewModel
        return viewModel
    }

    /// Retrieves existing PollViewModel for the asset without creating a new one.
    /// - Parameter assetId: Unique identifier for the asset
    /// - Returns: PollViewModel if it exists, nil otherwise
    func get(for assetId: String) -> PollViewModel? {
        viewModels[assetId]
    }

    /// Removes PollViewModel for the specified asset.
    /// - Parameter assetId: Unique identifier for the asset
    func remove(for assetId: String) {
        viewModels.removeValue(forKey: assetId)
    }

    /// Clears all cached PollViewModels.
    func clear() {
        viewModels.removeAll()
    }

    /// Number of cached PollViewModels.
    var count: Int {
        viewModels.count
    }
}
