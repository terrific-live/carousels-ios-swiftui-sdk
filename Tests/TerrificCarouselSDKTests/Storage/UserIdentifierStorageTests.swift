//
//  UserIdentifierStorageTests.swift
//  TerrificCarouselSDKTests
//

import XCTest
@testable import TerrificCarouselSDK

final class UserIdentifierStorageTests: XCTestCase {

    // MARK: - Properties
    private var sut: UserDefaultsUserIdentifierStorage!
    private var testUserDefaults: UserDefaults!

    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        testUserDefaults = UserDefaults(suiteName: "UserIdentifierStorageTests")!
        testUserDefaults.removePersistentDomain(forName: "UserIdentifierStorageTests")
        sut = UserDefaultsUserIdentifierStorage(userDefaults: testUserDefaults)
    }

    override func tearDown() {
        testUserDefaults.removePersistentDomain(forName: "UserIdentifierStorageTests")
        sut = nil
        testUserDefaults = nil
        super.tearDown()
    }

    // MARK: - UserId Generation Tests

    func testUserId_firstAccess_generatesNewId() {
        // When
        let userId = sut.userId

        // Then
        XCTAssertFalse(userId.isEmpty)
    }

    func testUserId_firstAccess_generatesValidUUID() {
        // When
        let userId = sut.userId

        // Then
        XCTAssertNotNil(UUID(uuidString: userId), "userId should be a valid UUID")
    }

    func testUserId_subsequentAccess_returnsSameId() {
        // When
        let firstAccess = sut.userId
        let secondAccess = sut.userId
        let thirdAccess = sut.userId

        // Then
        XCTAssertEqual(firstAccess, secondAccess)
        XCTAssertEqual(secondAccess, thirdAccess)
    }

    // MARK: - Clear Tests

    func testClear_removesStoredId() {
        // Given
        let originalId = sut.userId

        // When
        sut.clear()
        let newId = sut.userId

        // Then
        XCTAssertNotEqual(originalId, newId, "After clear, a new ID should be generated")
    }

    func testClear_nextAccessGeneratesValidUUID() {
        // Given
        _ = sut.userId
        sut.clear()

        // When
        let newId = sut.userId

        // Then
        XCTAssertNotNil(UUID(uuidString: newId), "New userId should be a valid UUID")
    }

    func testClear_onEmptyStorage_doesNothing() {
        // When - clear without accessing userId first
        sut.clear()

        // Then - should still be able to get a new userId
        let userId = sut.userId
        XCTAssertFalse(userId.isEmpty)
        XCTAssertNotNil(UUID(uuidString: userId))
    }

    // MARK: - Persistence Tests

    func testUserId_persistsAcrossInstances() {
        // Given
        let originalId = sut.userId

        // When - create new instance with same UserDefaults
        let newStorage = UserDefaultsUserIdentifierStorage(userDefaults: testUserDefaults)
        let retrievedId = newStorage.userId

        // Then
        XCTAssertEqual(originalId, retrievedId)
    }

    func testClear_persistsAcrossInstances() {
        // Given
        let originalId = sut.userId
        sut.clear()

        // When - create new instance with same UserDefaults
        let newStorage = UserDefaultsUserIdentifierStorage(userDefaults: testUserDefaults)
        let newId = newStorage.userId

        // Then - new instance should generate new ID
        XCTAssertNotEqual(originalId, newId)
    }

    // MARK: - Cache Behavior Tests

    func testUserId_cachesPersistentValue() {
        // Given - access userId to trigger storage
        let firstAccess = sut.userId

        // When - modify underlying UserDefaults directly
        testUserDefaults.set("different-value", forKey: "com.carouseldemo.terrificUserId")

        // Then - cached value should be returned (not the modified one)
        let cachedAccess = sut.userId
        XCTAssertEqual(firstAccess, cachedAccess)
    }

    func testUserId_afterClear_readsFromStorage() {
        // Given
        _ = sut.userId
        sut.clear()

        // Manually set a value in UserDefaults
        let manualId = "manually-set-id"
        testUserDefaults.set(manualId, forKey: "com.carouseldemo.terrificUserId")

        // When - create new instance (simulates clear + new instance)
        let newStorage = UserDefaultsUserIdentifierStorage(userDefaults: testUserDefaults)

        // Then
        XCTAssertEqual(newStorage.userId, manualId)
    }

    // MARK: - Multiple Storage Instances Tests

    func testMultipleInstances_shareData() {
        // Given
        let storage1 = UserDefaultsUserIdentifierStorage(userDefaults: testUserDefaults)
        let storage2 = UserDefaultsUserIdentifierStorage(userDefaults: testUserDefaults)

        // When
        let id1 = storage1.userId

        // Then - storage2 should see the same ID (from UserDefaults)
        let newStorage2 = UserDefaultsUserIdentifierStorage(userDefaults: testUserDefaults)
        let id2 = newStorage2.userId
        XCTAssertEqual(id1, id2)
    }
}

// MARK: - MockUserIdentifierStorage Tests
final class MockUserIdentifierStorageTests: XCTestCase {

    private var sut: MockUserIdentifierStorage!

    override func setUp() {
        super.setUp()
        sut = MockUserIdentifierStorage()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testUserId_returnsDefaultMockId() {
        // When
        let userId = sut.userId

        // Then
        XCTAssertEqual(userId, "mock-user-id")
    }

    func testUserId_returnsCustomMockId() {
        // Given
        sut.mockUserId = "custom-test-id"

        // When
        let userId = sut.userId

        // Then
        XCTAssertEqual(userId, "custom-test-id")
    }

    func testUserId_subsequentAccess_returnsSameId() {
        // When
        let firstAccess = sut.userId
        let secondAccess = sut.userId

        // Then
        XCTAssertEqual(firstAccess, secondAccess)
    }

    func testClear_resetsStoredId() {
        // Given
        _ = sut.userId

        // When
        sut.clear()
        sut.mockUserId = "new-mock-id"
        let newId = sut.userId

        // Then
        XCTAssertEqual(newId, "new-mock-id")
    }

    func testChangingMockUserId_afterFirstAccess_doesNotChangeStoredId() {
        // Given
        let firstId = sut.userId
        XCTAssertEqual(firstId, "mock-user-id")

        // When
        sut.mockUserId = "changed-id"
        let secondId = sut.userId

        // Then - stored value should still be the original
        XCTAssertEqual(secondId, "mock-user-id")
    }

    func testChangingMockUserId_afterClear_usesNewId() {
        // Given
        _ = sut.userId
        sut.clear()

        // When
        sut.mockUserId = "new-id-after-clear"
        let newId = sut.userId

        // Then
        XCTAssertEqual(newId, "new-id-after-clear")
    }
}
