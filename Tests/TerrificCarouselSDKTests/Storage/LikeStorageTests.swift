//
//  LikeStorageTests.swift
//  TerrificCarouselSDKTests
//

import XCTest
@testable import TerrificCarouselSDK

@MainActor
final class LikeStorageTests: XCTestCase {

    // MARK: - Properties
    private var sut: UserDefaultsLikeStorage!
    private var testUserDefaults: UserDefaults!

    // MARK: - Setup & Teardown
    override func setUp() async throws {
        try await super.setUp()
        testUserDefaults = UserDefaults(suiteName: "LikeStorageTests")!
        testUserDefaults.removePersistentDomain(forName: "LikeStorageTests")
        sut = UserDefaultsLikeStorage(userDefaults: testUserDefaults)
    }

    override func tearDown() async throws {
        testUserDefaults.removePersistentDomain(forName: "LikeStorageTests")
        sut = nil
        testUserDefaults = nil
        try await super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState_noLikedAssets() {
        XCTAssertFalse(sut.isLiked("any-asset"))
        XCTAssertTrue(sut.allLikedIds().isEmpty)
    }

    // MARK: - SetLiked Tests

    func testSetLiked_true_marksAssetAsLiked() {
        // When
        sut.setLiked("asset-1", isLiked: true)

        // Then
        XCTAssertTrue(sut.isLiked("asset-1"))
    }

    func testSetLiked_false_unmarksAsset() {
        // Given
        sut.setLiked("asset-1", isLiked: true)
        XCTAssertTrue(sut.isLiked("asset-1"))

        // When
        sut.setLiked("asset-1", isLiked: false)

        // Then
        XCTAssertFalse(sut.isLiked("asset-1"))
    }

    func testSetLiked_multipleAssets_trackedSeparately() {
        // When
        sut.setLiked("asset-1", isLiked: true)
        sut.setLiked("asset-2", isLiked: true)
        sut.setLiked("asset-3", isLiked: false)

        // Then
        XCTAssertTrue(sut.isLiked("asset-1"))
        XCTAssertTrue(sut.isLiked("asset-2"))
        XCTAssertFalse(sut.isLiked("asset-3"))
    }

    func testSetLiked_duplicate_noEffect() {
        // When - like same asset multiple times
        sut.setLiked("asset-1", isLiked: true)
        sut.setLiked("asset-1", isLiked: true)
        sut.setLiked("asset-1", isLiked: true)

        // Then - still just one entry
        XCTAssertEqual(sut.allLikedIds().count, 1)
        XCTAssertTrue(sut.isLiked("asset-1"))
    }

    // MARK: - AllLikedIds Tests

    func testAllLikedIds_returnsAllLikedAssets() {
        // Given
        sut.setLiked("asset-1", isLiked: true)
        sut.setLiked("asset-2", isLiked: true)
        sut.setLiked("asset-3", isLiked: true)

        // When
        let allIds = sut.allLikedIds()

        // Then
        XCTAssertEqual(allIds.count, 3)
        XCTAssertTrue(allIds.contains("asset-1"))
        XCTAssertTrue(allIds.contains("asset-2"))
        XCTAssertTrue(allIds.contains("asset-3"))
    }

    func testAllLikedIds_excludesUnlikedAssets() {
        // Given
        sut.setLiked("asset-1", isLiked: true)
        sut.setLiked("asset-2", isLiked: true)
        sut.setLiked("asset-1", isLiked: false) // Unlike

        // When
        let allIds = sut.allLikedIds()

        // Then
        XCTAssertEqual(allIds.count, 1)
        XCTAssertFalse(allIds.contains("asset-1"))
        XCTAssertTrue(allIds.contains("asset-2"))
    }

    // MARK: - ClearAll Tests

    func testClearAll_removesAllLikes() {
        // Given
        sut.setLiked("asset-1", isLiked: true)
        sut.setLiked("asset-2", isLiked: true)
        sut.setLiked("asset-3", isLiked: true)
        XCTAssertEqual(sut.allLikedIds().count, 3)

        // When
        sut.clearAll()

        // Then
        XCTAssertTrue(sut.allLikedIds().isEmpty)
        XCTAssertFalse(sut.isLiked("asset-1"))
        XCTAssertFalse(sut.isLiked("asset-2"))
        XCTAssertFalse(sut.isLiked("asset-3"))
    }

    func testClearAll_emptyStorage_noError() {
        // When - clear empty storage
        sut.clearAll()

        // Then - no error, still empty
        XCTAssertTrue(sut.allLikedIds().isEmpty)
    }

    // MARK: - Persistence Tests

    func testLikes_persistAcrossInstances() {
        // Given
        sut.setLiked("asset-1", isLiked: true)
        sut.setLiked("asset-2", isLiked: true)

        // When - create new instance with same UserDefaults
        let newStorage = UserDefaultsLikeStorage(userDefaults: testUserDefaults)

        // Then
        XCTAssertTrue(newStorage.isLiked("asset-1"))
        XCTAssertTrue(newStorage.isLiked("asset-2"))
        XCTAssertEqual(newStorage.allLikedIds().count, 2)
    }

    func testClearAll_persistsAcrossInstances() {
        // Given
        sut.setLiked("asset-1", isLiked: true)
        sut.clearAll()

        // When - create new instance
        let newStorage = UserDefaultsLikeStorage(userDefaults: testUserDefaults)

        // Then
        XCTAssertFalse(newStorage.isLiked("asset-1"))
        XCTAssertTrue(newStorage.allLikedIds().isEmpty)
    }

    // MARK: - Edge Cases

    func testIsLiked_emptyAssetId_works() {
        // When
        sut.setLiked("", isLiked: true)

        // Then
        XCTAssertTrue(sut.isLiked(""))
    }

    func testIsLiked_specialCharacters_works() {
        // Given
        let specialId = "asset/with:special@chars#123"

        // When
        sut.setLiked(specialId, isLiked: true)

        // Then
        XCTAssertTrue(sut.isLiked(specialId))
    }
}

// MARK: - MockLikeStorage Tests
@MainActor
final class MockLikeStorageTests: XCTestCase {

    private var sut: MockLikeStorage!

    override func setUp() async throws {
        try await super.setUp()
        sut = MockLikeStorage()
    }

    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }

    func testMockStorage_setLiked_works() {
        // When
        sut.setLiked("asset-1", isLiked: true)

        // Then
        XCTAssertTrue(sut.isLiked("asset-1"))
    }

    func testMockStorage_allLikedIds_works() {
        // Given
        sut.setLiked("asset-1", isLiked: true)
        sut.setLiked("asset-2", isLiked: true)

        // Then
        XCTAssertEqual(sut.allLikedIds().count, 2)
    }

    func testMockStorage_clearAll_works() {
        // Given
        sut.setLiked("asset-1", isLiked: true)

        // When
        sut.clearAll()

        // Then
        XCTAssertFalse(sut.isLiked("asset-1"))
        XCTAssertTrue(sut.allLikedIds().isEmpty)
    }
}
