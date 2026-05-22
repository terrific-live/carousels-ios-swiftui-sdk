//
//  PollAnswerStorageTests.swift
//  TerrificCarouselSDKTests
//

import XCTest
@testable import TerrificCarouselSDK

@MainActor
final class PollAnswerStorageTests: XCTestCase {

    // MARK: - Properties
    private var sut: UserDefaultsPollAnswerStorage!
    private var testUserDefaults: UserDefaults!

    // MARK: - Setup & Teardown
    override func setUp() async throws {
        try await super.setUp()
        // Use a separate suite for testing to avoid polluting real UserDefaults
        testUserDefaults = UserDefaults(suiteName: "PollAnswerStorageTests")!
        testUserDefaults.removePersistentDomain(forName: "PollAnswerStorageTests")
        sut = UserDefaultsPollAnswerStorage(userDefaults: testUserDefaults)
    }

    override func tearDown() async throws {
        testUserDefaults.removePersistentDomain(forName: "PollAnswerStorageTests")
        sut = nil
        testUserDefaults = nil
        try await super.tearDown()
    }

    // MARK: - Save and Get Tests

    func testSaveAnswer_canBeRetrieved() {
        // Given
        let answer = PollAnswer(
            pollId: "poll-1",
            selectedOptionIndex: 2,
            selectedOptionText: "Blue",
            answeredAt: Date()
        )

        // When
        sut.saveAnswer(answer)
        let retrieved = sut.getAnswer(for: "poll-1")

        // Then
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.pollId, "poll-1")
        XCTAssertEqual(retrieved?.selectedOptionIndex, 2)
        XCTAssertEqual(retrieved?.selectedOptionText, "Blue")
    }

    func testGetAnswer_nonExistingPoll_returnsNil() {
        // When
        let result = sut.getAnswer(for: "non-existing-poll")

        // Then
        XCTAssertNil(result)
    }

    func testSaveAnswer_overwritesPreviousAnswer() {
        // Given
        let firstAnswer = PollAnswer(
            pollId: "poll-1",
            selectedOptionIndex: 0,
            selectedOptionText: "Red",
            answeredAt: Date()
        )
        let secondAnswer = PollAnswer(
            pollId: "poll-1",
            selectedOptionIndex: 1,
            selectedOptionText: "Blue",
            answeredAt: Date()
        )

        // When
        sut.saveAnswer(firstAnswer)
        sut.saveAnswer(secondAnswer)
        let retrieved = sut.getAnswer(for: "poll-1")

        // Then
        XCTAssertEqual(retrieved?.selectedOptionIndex, 1)
        XCTAssertEqual(retrieved?.selectedOptionText, "Blue")
    }

    func testSaveAnswer_multiplePolls_areStoredSeparately() {
        // Given
        let answer1 = PollAnswer(
            pollId: "poll-1",
            selectedOptionIndex: 0,
            selectedOptionText: "A",
            answeredAt: Date()
        )
        let answer2 = PollAnswer(
            pollId: "poll-2",
            selectedOptionIndex: 1,
            selectedOptionText: "B",
            answeredAt: Date()
        )

        // When
        sut.saveAnswer(answer1)
        sut.saveAnswer(answer2)

        // Then
        XCTAssertEqual(sut.getAnswer(for: "poll-1")?.selectedOptionText, "A")
        XCTAssertEqual(sut.getAnswer(for: "poll-2")?.selectedOptionText, "B")
    }

    // MARK: - Remove Tests

    func testRemoveAnswer_existingPoll_removesAnswer() {
        // Given
        let answer = PollAnswer(
            pollId: "poll-1",
            selectedOptionIndex: 0,
            selectedOptionText: "Red",
            answeredAt: Date()
        )
        sut.saveAnswer(answer)
        XCTAssertNotNil(sut.getAnswer(for: "poll-1"))

        // When
        sut.removeAnswer(for: "poll-1")

        // Then
        XCTAssertNil(sut.getAnswer(for: "poll-1"))
    }

    func testRemoveAnswer_nonExistingPoll_doesNothing() {
        // Given
        let answer = PollAnswer(
            pollId: "poll-1",
            selectedOptionIndex: 0,
            selectedOptionText: "Red",
            answeredAt: Date()
        )
        sut.saveAnswer(answer)

        // When - remove non-existing
        sut.removeAnswer(for: "poll-2")

        // Then - poll-1 still exists
        XCTAssertNotNil(sut.getAnswer(for: "poll-1"))
    }

    // MARK: - Clear All Tests

    func testClearAll_removesAllAnswers() {
        // Given
        sut.saveAnswer(PollAnswer(pollId: "poll-1", selectedOptionIndex: 0, selectedOptionText: "A", answeredAt: Date()))
        sut.saveAnswer(PollAnswer(pollId: "poll-2", selectedOptionIndex: 1, selectedOptionText: "B", answeredAt: Date()))
        sut.saveAnswer(PollAnswer(pollId: "poll-3", selectedOptionIndex: 2, selectedOptionText: "C", answeredAt: Date()))

        // When
        sut.clearAll()

        // Then
        XCTAssertNil(sut.getAnswer(for: "poll-1"))
        XCTAssertNil(sut.getAnswer(for: "poll-2"))
        XCTAssertNil(sut.getAnswer(for: "poll-3"))
    }

    // MARK: - Persistence Tests

    func testAnswers_persistAcrossInstances() {
        // Given
        let answer = PollAnswer(
            pollId: "poll-1",
            selectedOptionIndex: 2,
            selectedOptionText: "Green",
            answeredAt: Date()
        )
        sut.saveAnswer(answer)

        // When - create new instance with same UserDefaults
        let newStorage = UserDefaultsPollAnswerStorage(userDefaults: testUserDefaults)
        let retrieved = newStorage.getAnswer(for: "poll-1")

        // Then
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.selectedOptionText, "Green")
    }

    // MARK: - Date Persistence Tests

    func testAnsweredAt_dateIsPersisted() {
        // Given
        let specificDate = Date(timeIntervalSince1970: 1700000000) // Fixed date for testing
        let answer = PollAnswer(
            pollId: "poll-1",
            selectedOptionIndex: 0,
            selectedOptionText: "A",
            answeredAt: specificDate
        )

        // When
        sut.saveAnswer(answer)
        let retrieved = sut.getAnswer(for: "poll-1")

        // Then
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved!.answeredAt.timeIntervalSince1970, specificDate.timeIntervalSince1970, accuracy: 1.0)
    }
}

// MARK: - MockPollAnswerStorage Tests
@MainActor
final class MockPollAnswerStorageTests: XCTestCase {

    private var sut: MockPollAnswerStorage!

    override func setUp() async throws {
        try await super.setUp()
        sut = MockPollAnswerStorage()
    }

    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }

    func testMockStorage_savesAndRetrieves() {
        // Given
        let answer = PollAnswer(
            pollId: "poll-1",
            selectedOptionIndex: 0,
            selectedOptionText: "Test",
            answeredAt: Date()
        )

        // When
        sut.saveAnswer(answer)
        let retrieved = sut.getAnswer(for: "poll-1")

        // Then
        XCTAssertNotNil(retrieved)
        XCTAssertEqual(retrieved?.selectedOptionText, "Test")
    }

    func testMockStorage_clearAll() {
        // Given
        sut.saveAnswer(PollAnswer(pollId: "1", selectedOptionIndex: 0, selectedOptionText: "A", answeredAt: Date()))
        sut.saveAnswer(PollAnswer(pollId: "2", selectedOptionIndex: 0, selectedOptionText: "B", answeredAt: Date()))

        // When
        sut.clearAll()

        // Then
        XCTAssertNil(sut.getAnswer(for: "1"))
        XCTAssertNil(sut.getAnswer(for: "2"))
    }
}
