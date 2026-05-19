//
//  PollViewModelStoreTests.swift
//  TerrificCarouselSDKTests
//

import XCTest
@testable import TerrificCarouselSDK

@MainActor
final class PollViewModelStoreTests: XCTestCase {

    // MARK: - Properties
    private var sut: PollViewModelStore!
    private var mockPollService: MockPollService!
    private var mockAnswerStorage: MockPollAnswerStorage!
    private var mockAnalyticDelegate: MockPollViewModelAnalyticDelegate!

    // MARK: - Setup & Teardown
    override func setUp() async throws {
        try await super.setUp()
        mockPollService = MockPollService()
        mockAnswerStorage = MockPollAnswerStorage()
        mockAnalyticDelegate = MockPollViewModelAnalyticDelegate()

        sut = PollViewModelStore(
            pollService: mockPollService,
            answerStorage: mockAnswerStorage
        )
    }

    override func tearDown() async throws {
        sut = nil
        mockPollService = nil
        mockAnswerStorage = nil
        mockAnalyticDelegate = nil
        try await super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState_isEmpty() {
        XCTAssertEqual(sut.count, 0)
    }

    // MARK: - GetOrCreate Tests

    func testGetOrCreate_createsNewViewModel() {
        // Given
        let pollData = PollData.sample

        // When
        let viewModel = sut.getOrCreate(for: "asset-1", pollData: pollData)

        // Then
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel?.assetId, "asset-1")
        XCTAssertEqual(sut.count, 1)
    }

    func testGetOrCreate_returnsExistingViewModel() {
        // Given
        let pollData = PollData.sample
        let first = sut.getOrCreate(for: "asset-1", pollData: pollData)

        // When
        let second = sut.getOrCreate(for: "asset-1", pollData: pollData)

        // Then - should return same instance
        XCTAssertTrue(first === second)
        XCTAssertEqual(sut.count, 1)
    }

    func testGetOrCreate_withNilPollData_returnsNil() {
        // When
        let viewModel = sut.getOrCreate(for: "asset-1", pollData: nil)

        // Then
        XCTAssertNil(viewModel)
        XCTAssertEqual(sut.count, 0)
    }

    func testGetOrCreate_existingWithNilPollData_returnsExisting() {
        // Given - create first
        let pollData = PollData.sample
        let first = sut.getOrCreate(for: "asset-1", pollData: pollData)

        // When - call again with nil
        let second = sut.getOrCreate(for: "asset-1", pollData: nil)

        // Then - should return existing
        XCTAssertTrue(first === second)
    }

    func testGetOrCreate_restoresPreviousAnswer() {
        // Given - saved answer in storage
        let savedAnswer = PollAnswer(
            pollId: "poll-1",
            selectedOptionIndex: 1,
            selectedOptionText: "Blue",
            answeredAt: Date()
        )
        mockAnswerStorage.saveAnswer(savedAnswer)

        // When
        let viewModel = sut.getOrCreate(for: "asset-1", pollData: .sample)

        // Then - should be marked as answered
        XCTAssertTrue(viewModel?.isAnswered ?? false)
        XCTAssertEqual(viewModel?.selectedOptionIndex, 1)
    }

    func testGetOrCreate_withoutPreviousAnswer_notAnswered() {
        // Given - no saved answer

        // When
        let viewModel = sut.getOrCreate(for: "asset-1", pollData: .sample)

        // Then - should not be answered
        XCTAssertFalse(viewModel?.isAnswered ?? true)
        XCTAssertNil(viewModel?.selectedOptionIndex)
    }

    // MARK: - Get Tests

    func testGet_existingAsset_returnsViewModel() {
        // Given
        _ = sut.getOrCreate(for: "asset-1", pollData: .sample)

        // When
        let retrieved = sut.get(for: "asset-1")

        // Then
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.assetId, "asset-1")
    }

    func testGet_nonExistingAsset_returnsNil() {
        // When
        let retrieved = sut.get(for: "non-existing")

        // Then
        XCTAssertNil(retrieved)
    }

    // MARK: - Remove Tests

    func testRemove_existingAsset_removesViewModel() {
        // Given
        _ = sut.getOrCreate(for: "asset-1", pollData: .sample)
        XCTAssertEqual(sut.count, 1)

        // When
        sut.remove(for: "asset-1")

        // Then
        XCTAssertEqual(sut.count, 0)
        XCTAssertNil(sut.get(for: "asset-1"))
    }

    func testRemove_nonExistingAsset_doesNothing() {
        // Given
        _ = sut.getOrCreate(for: "asset-1", pollData: .sample)

        // When
        sut.remove(for: "non-existing")

        // Then
        XCTAssertEqual(sut.count, 1)
    }

    // MARK: - Clear Tests

    func testClear_removesAllViewModels() {
        // Given
        _ = sut.getOrCreate(for: "asset-1", pollData: .sample)
        _ = sut.getOrCreate(for: "asset-2", pollData: .sample)
        _ = sut.getOrCreate(for: "asset-3", pollData: .sample)
        XCTAssertEqual(sut.count, 3)

        // When
        sut.clear()

        // Then
        XCTAssertEqual(sut.count, 0)
    }

    // MARK: - Analytic Delegate Tests

    func testAnalyticDelegate_forwardsToNewViewModels() {
        // Given
        sut.analyticDelegate = mockAnalyticDelegate

        // When
        let viewModel = sut.getOrCreate(for: "asset-1", pollData: .sample)

        // Then
        XCTAssertTrue(viewModel?.analyticDelegate === mockAnalyticDelegate)
    }

    func testAnalyticDelegate_updatesExistingViewModels() {
        // Given
        let viewModel = sut.getOrCreate(for: "asset-1", pollData: .sample)
        XCTAssertNil(viewModel?.analyticDelegate)

        // When
        sut.analyticDelegate = mockAnalyticDelegate

        // Then
        XCTAssertTrue(viewModel?.analyticDelegate === mockAnalyticDelegate)
    }

    // MARK: - Multiple Assets Tests

    func testMultipleAssets_createsSeparateViewModels() {
        // Given
        let poll1 = PollData.sample(id: "poll-1", question: "Question 1?")
        let poll2 = PollData.sample(id: "poll-2", question: "Question 2?")

        // When
        let vm1 = sut.getOrCreate(for: "asset-1", pollData: poll1)
        let vm2 = sut.getOrCreate(for: "asset-2", pollData: poll2)

        // Then
        XCTAssertNotNil(vm1)
        XCTAssertNotNil(vm2)
        XCTAssertFalse(vm1 === vm2)
        XCTAssertEqual(sut.count, 2)
    }

    // MARK: - State Persistence Tests

    func testStatePersistedAcrossCalls() async throws {
        // Given
        mockPollService.stubbedOptions = [
            PollOptionDTO(text: "Red", numberOfVotes: 11),
            PollOptionDTO(text: "Blue", numberOfVotes: 20),
            PollOptionDTO(text: "Green", numberOfVotes: 15)
        ]
        sut.analyticDelegate = mockAnalyticDelegate

        let viewModel1 = sut.getOrCreate(for: "asset-1", pollData: .sample)

        // When - user votes
        viewModel1?.handleSelectOption(0)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then - get same view model, should have state preserved
        let viewModel2 = sut.getOrCreate(for: "asset-1", pollData: .sample)
        XCTAssertTrue(viewModel2?.isAnswered ?? false)
        XCTAssertEqual(viewModel2?.selectedOptionIndex, 0)
    }

    // MARK: - Service Injection Tests

    func testCreatedViewModels_havePollService() async throws {
        // Given
        mockPollService.stubbedOptions = [
            PollOptionDTO(text: "Red", numberOfVotes: 11),
            PollOptionDTO(text: "Blue", numberOfVotes: 20),
            PollOptionDTO(text: "Green", numberOfVotes: 15)
        ]

        // When
        let viewModel = sut.getOrCreate(for: "asset-1", pollData: .sample)
        viewModel?.handleSelectOption(0)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then - should have called poll service
        XCTAssertEqual(mockPollService.voteCallCount, 1)
    }

    func testCreatedViewModels_haveAnswerStorage() async throws {
        // Given
        mockPollService.stubbedOptions = [
            PollOptionDTO(text: "Red", numberOfVotes: 11),
            PollOptionDTO(text: "Blue", numberOfVotes: 20),
            PollOptionDTO(text: "Green", numberOfVotes: 15)
        ]

        // When
        let viewModel = sut.getOrCreate(for: "asset-1", pollData: .sample)
        viewModel?.handleSelectOption(0)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then - should have saved to storage
        XCTAssertNotNil(mockAnswerStorage.getAnswer(for: "poll-1"))
    }
}
