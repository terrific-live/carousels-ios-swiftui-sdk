//
//  MockUserIdentifierStorage.swift
//  TerrificCarouselSDKTests
//

@testable import TerrificCarouselSDK

final class MockUserIdentifierStorage: UserIdentifierStorage {
    private var storedUserId: String?

    /// Allows setting a specific userId for testing
    var mockUserId: String = "mock-user-id"

    var userId: String {
        if let stored = storedUserId {
            return stored
        }
        storedUserId = mockUserId
        return mockUserId
    }

    func clear() {
        storedUserId = nil
    }
}
