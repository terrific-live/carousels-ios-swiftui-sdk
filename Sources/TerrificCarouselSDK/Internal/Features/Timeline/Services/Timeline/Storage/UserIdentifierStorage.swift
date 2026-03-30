//
//  UserIdentifierStorage.swift
//  CarouselDemo
//

import Foundation

// MARK: - UserIdentifierStorage Protocol
/// Storage for managing persistent user identifier.
/// Generates a UUID on first access and persists it for future sessions.
protocol UserIdentifierStorage {
    /// Returns the persistent user identifier.
    /// Generates and stores a new UUID if none exists.
    var userId: String { get }

    /// Clears the stored user identifier.
    /// Next access to `userId` will generate a new one.
    func clear()
}

// MARK: - UserDefaultsUserIdentifierStorage
final class UserDefaultsUserIdentifierStorage: UserIdentifierStorage {

    // MARK: - Constants
    private enum Keys {
        static let userId = "com.carouseldemo.terrificUserId"
    }

    // MARK: - Dependencies
    private let userDefaults: UserDefaults

    // MARK: - Cache
    /// In-memory cache to avoid repeated UserDefaults reads
    private var cachedUserId: String?

    // MARK: - Init
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - UserIdentifierStorage
    var userId: String {
        if let cached = cachedUserId {
            return cached
        }

        if let stored = userDefaults.string(forKey: Keys.userId) {
            cachedUserId = stored
            return stored
        }

        let newId = UUID().uuidString
        userDefaults.set(newId, forKey: Keys.userId)
        cachedUserId = newId
        return newId
    }

    func clear() {
        cachedUserId = nil
        userDefaults.removeObject(forKey: Keys.userId)
    }
}

// MARK: - Mock Implementation
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
