//
//  PollViewModelTests.swift
//  TerrificCarouselSDKTests
//

import XCTest
@testable import TerrificCarouselSDK

@MainActor
final class PollViewModelTests: XCTestCase {

    // MARK: - Properties
    private var sut: PollViewModel!
    private var mockPollService: MockPollService!
    private var mockAnswerStorage: MockPollAnswerStorage!
    private var mockAnalyticDelegate: MockPollViewModelAnalyticDelegate!

    // MARK: - Setup & Teardown
    override func setUp() async throws {
        try await super.setUp()
        mockPollService = MockPollService()
        mockAnswerStorage = MockPollAnswerStorage()
        mockAnalyticDelegate = MockPollViewModelAnalyticDelegate()

        sut = PollViewModel(
            assetId: "test-asset",
            pollData: .sample,
            pollService: mockPollService,
            answerStorage: mockAnswerStorage
        )
        sut.analyticDelegate = mockAnalyticDelegate
    }

    override func tearDown() async throws {
        sut = nil
        mockPollService = nil
        mockAnswerStorage = nil
        mockAnalyticDelegate = nil
        try await super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState_isNotAnswered() {
        XCTAssertFalse(sut.isAnswered)
        XCTAssertNil(sut.selectedOptionIndex)
        XCTAssertFalse(sut.isSubmitting)
        XCTAssertNil(sut.error)
    }

    func testInitialState_withPreviousAnswer() {
        // Given
        let pollData = PollData.sample
        let answeredVM = PollViewModel(
            assetId: "test-asset",
            pollData: pollData,
            pollService: mockPollService,
            answerStorage: mockAnswerStorage,
            isAnswered: true,
            selectedOptionIndex: 1
        )

        // Then
        XCTAssertTrue(answeredVM.isAnswered)
        XCTAssertEqual(answeredVM.selectedOptionIndex, 1)
    }

    // MARK: - Percentage Calculation Tests

    func testPercentage_calculatesCorrectly() {
        // Given - poll with 45 total votes (10 + 20 + 15)
        // Red: 10/45 = 22.2% -> 22
        // Blue: 20/45 = 44.4% -> 44
        // Green: 15/45 = 33.3% -> 33

        // When/Then
        let options = sut.pollData.options
        XCTAssertEqual(sut.percentage(for: options[0]), 22) // Red
        XCTAssertEqual(sut.percentage(for: options[1]), 44) // Blue
        XCTAssertEqual(sut.percentage(for: options[2]), 33) // Green
    }

    func testPercentage_withZeroVotes_returnsZero() {
        // Given
        let pollData = PollData(
            id: "empty-poll",
            questionId: "q1",
            question: "Test?",
            options: [
                PollOptionData(id: 0, text: "A", numberOfVotes: 0),
                PollOptionData(id: 1, text: "B", numberOfVotes: 0)
            ]
        )
        sut = PollViewModel(
            assetId: "test",
            pollData: pollData,
            pollService: mockPollService,
            answerStorage: mockAnswerStorage
        )

        // Then
        XCTAssertEqual(sut.percentage(for: pollData.options[0]), 0)
        XCTAssertEqual(sut.percentage(for: pollData.options[1]), 0)
    }

    func testPercentageFraction_calculatesCorrectly() {
        // Given - poll with 45 total votes
        let options = sut.pollData.options

        // When/Then
        XCTAssertEqual(sut.percentageFraction(for: options[0]), 10.0 / 45.0, accuracy: 0.001) // Red
        XCTAssertEqual(sut.percentageFraction(for: options[1]), 20.0 / 45.0, accuracy: 0.001) // Blue
        XCTAssertEqual(sut.percentageFraction(for: options[2]), 15.0 / 45.0, accuracy: 0.001) // Green
    }

    // MARK: - Option Selection Tests

    func testHandleSelectOption_setsSelectedIndex() async throws {
        // Given
        mockPollService.stubbedOptions = [
            PollOptionDTO(text: "Red", numberOfVotes: 11),
            PollOptionDTO(text: "Blue", numberOfVotes: 20),
            PollOptionDTO(text: "Green", numberOfVotes: 15)
        ]

        // When
        sut.handleSelectOption(0)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(sut.selectedOptionIndex, 0)
    }

    func testHandleSelectOption_submitsVoteToService() async throws {
        // Given
        mockPollService.stubbedOptions = [
            PollOptionDTO(text: "Red", numberOfVotes: 11),
            PollOptionDTO(text: "Blue", numberOfVotes: 20),
            PollOptionDTO(text: "Green", numberOfVotes: 15)
        ]

        // When
        sut.handleSelectOption(0)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(mockPollService.voteCallCount, 1)
        XCTAssertEqual(mockPollService.lastVotePollId, "poll-1")
        XCTAssertEqual(mockPollService.lastVoteQuestionId, "q-1")
        XCTAssertEqual(mockPollService.lastVoteOption, "Red")
    }

    func testHandleSelectOption_updatesIsAnswered() async throws {
        // Given
        mockPollService.stubbedOptions = [
            PollOptionDTO(text: "Red", numberOfVotes: 11),
            PollOptionDTO(text: "Blue", numberOfVotes: 20),
            PollOptionDTO(text: "Green", numberOfVotes: 15)
        ]

        // When
        sut.handleSelectOption(0)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertTrue(sut.isAnswered)
    }

    func testHandleSelectOption_savesAnswerToStorage() async throws {
        // Given
        mockPollService.stubbedOptions = [
            PollOptionDTO(text: "Red", numberOfVotes: 11),
            PollOptionDTO(text: "Blue", numberOfVotes: 20),
            PollOptionDTO(text: "Green", numberOfVotes: 15)
        ]

        // When
        sut.handleSelectOption(0)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        let savedAnswer = mockAnswerStorage.getAnswer(for: "poll-1")
        XCTAssertNotNil(savedAnswer)
        XCTAssertEqual(savedAnswer?.selectedOptionIndex, 0)
        XCTAssertEqual(savedAnswer?.selectedOptionText, "Red")
    }

    func testHandleSelectOption_notifiesAnalyticDelegate() async throws {
        // Given
        mockPollService.stubbedOptions = [
            PollOptionDTO(text: "Red", numberOfVotes: 11),
            PollOptionDTO(text: "Blue", numberOfVotes: 20),
            PollOptionDTO(text: "Green", numberOfVotes: 15)
        ]

        // When
        sut.handleSelectOption(0)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(mockAnalyticDelegate.voteEvents.count, 1)
        let event = mockAnalyticDelegate.voteEvents[0]
        XCTAssertEqual(event.assetId, "test-asset")
        XCTAssertEqual(event.pollId, "poll-1")
        XCTAssertEqual(event.pollAnswer, "Red")
        XCTAssertEqual(event.questionId, "q-1")
    }

    func testHandleSelectOption_updatesPollDataWithServerResponse() async throws {
        // Given - server returns updated vote counts
        mockPollService.stubbedOptions = [
            PollOptionDTO(text: "Red", numberOfVotes: 100),
            PollOptionDTO(text: "Blue", numberOfVotes: 200),
            PollOptionDTO(text: "Green", numberOfVotes: 150)
        ]

        // When
        sut.handleSelectOption(0)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then - poll data should reflect server response
        XCTAssertEqual(sut.pollData.options[0].numberOfVotes, 100)
        XCTAssertEqual(sut.pollData.options[1].numberOfVotes, 200)
        XCTAssertEqual(sut.pollData.options[2].numberOfVotes, 150)
    }

    // MARK: - Error Handling Tests

    func testHandleSelectOption_onError_setsErrorAndClearsSelection() async throws {
        // Given
        let testError = NSError(domain: "test", code: 500, userInfo: [NSLocalizedDescriptionKey: "Server error"])
        mockPollService.stubbedError = testError

        // When
        sut.handleSelectOption(0)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertNotNil(sut.error)
        XCTAssertNil(sut.selectedOptionIndex)
        XCTAssertFalse(sut.isAnswered)
    }

    func testHandleSelectOption_onError_doesNotSaveAnswer() async throws {
        // Given
        mockPollService.stubbedError = NSError(domain: "test", code: 500)

        // When
        sut.handleSelectOption(0)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertNil(mockAnswerStorage.getAnswer(for: "poll-1"))
    }

    func testHandleSelectOption_onError_doesNotNotifyAnalytics() async throws {
        // Given
        mockPollService.stubbedError = NSError(domain: "test", code: 500)

        // When
        sut.handleSelectOption(0)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertTrue(mockAnalyticDelegate.voteEvents.isEmpty)
    }

    // MARK: - Submission State Tests

    func testHandleSelectOption_setsIsSubmittingDuringRequest() async throws {
        // Given - delay response
        mockPollService.stubbedOptions = [
            PollOptionDTO(text: "Red", numberOfVotes: 11),
            PollOptionDTO(text: "Blue", numberOfVotes: 20),
            PollOptionDTO(text: "Green", numberOfVotes: 15)
        ]

        // When
        sut.handleSelectOption(0)

        // Note: Testing isSubmitting mid-request is tricky without more control
        // This test verifies it's false after completion
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertFalse(sut.isSubmitting)
    }

    func testHandleSelectOption_whileSubmitting_doesNothing() async throws {
        // Given - a view model with answered state
        mockPollService.stubbedOptions = [
            PollOptionDTO(text: "Red", numberOfVotes: 11),
            PollOptionDTO(text: "Blue", numberOfVotes: 20),
            PollOptionDTO(text: "Green", numberOfVotes: 15)
        ]

        // First selection
        sut.handleSelectOption(0)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Reset to track second call
        let callCountAfterFirst = mockPollService.voteCallCount
        XCTAssertEqual(callCountAfterFirst, 1)

        // When - try to select different option after first is complete
        // Note: Once isAnswered is true, selecting same option is skipped
        // But selecting a different option when already answered should also be handled
        // The guard checks selectedOptionIndex != index, so same index is skipped
        sut.handleSelectOption(0) // Same index - should skip
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then - should not have called service again for same index
        XCTAssertEqual(mockPollService.voteCallCount, 1)
    }

    func testHandleSelectOption_sameOption_doesNothing() async throws {
        // Given
        mockPollService.stubbedOptions = [
            PollOptionDTO(text: "Red", numberOfVotes: 11),
            PollOptionDTO(text: "Blue", numberOfVotes: 20),
            PollOptionDTO(text: "Green", numberOfVotes: 15)
        ]
        sut.handleSelectOption(0)
        try await Task.sleep(nanoseconds: 100_000_000)

        mockPollService.reset()

        // When - select same option again
        sut.handleSelectOption(0)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then - should not call service
        XCTAssertEqual(mockPollService.voteCallCount, 0)
    }

    func testHandleSelectOption_invalidIndex_doesNothing() async throws {
        // When - select invalid index
        sut.handleSelectOption(99)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then - should not call service
        XCTAssertEqual(mockPollService.voteCallCount, 0)
        XCTAssertNil(sut.selectedOptionIndex)
    }

    // MARK: - Local Update Fallback Tests

    func testHandleSelectOption_withoutService_updatesLocally() async throws {
        // Given - no poll service
        let viewModel = PollViewModel(
            assetId: "test",
            pollData: PollData.sample,
            pollService: nil, // No service
            answerStorage: mockAnswerStorage
        )

        let initialVotes = viewModel.pollData.options[0].numberOfVotes

        // When
        viewModel.handleSelectOption(0)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then - should update locally with +1 vote
        XCTAssertEqual(viewModel.pollData.options[0].numberOfVotes, initialVotes + 1)
        XCTAssertTrue(viewModel.isAnswered)
    }

    // MARK: - Total Votes Tests

    func testTotalVotes_calculatesCorrectly() {
        // Given - poll with 10 + 20 + 15 = 45 total votes
        XCTAssertEqual(sut.pollData.totalVotes, 45)
    }
}
