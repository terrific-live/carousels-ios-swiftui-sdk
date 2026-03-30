//
//  LikeStorage.swift
//  CarouselDemo
//

import Foundation

// MARK: - LikeStorage Protocol
/// Storage for managing liked asset IDs.
/// All implementations are guaranteed to run on MainActor for thread safety.
@MainActor
protocol LikeStorage {
    /// Checks if an asset is liked.
    func isLiked(_ assetId: String) -> Bool

    /// Sets the like state for an asset.
    func setLiked(_ assetId: String, isLiked: Bool)

    /// Returns all liked asset IDs.
    func allLikedIds() -> Set<String>

    /// Clears all liked assets.
    func clearAll()
}

// MARK: - UserDefaultsLikeStorage
@MainActor
final class UserDefaultsLikeStorage: LikeStorage {

    // MARK: - Constants
    private enum Keys {
        static let likedAssetIds = "com.carouseldemo.likedAssetIds"
    }

    // MARK: - Dependencies
    private let userDefaults: UserDefaults

    // MARK: - Cache
    /// In-memory cache to avoid repeated UserDefaults reads
    private var cachedLikedIds: Set<String>?

    // MARK: - Init
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - LikeStorage
    func isLiked(_ assetId: String) -> Bool {
        loadIfNeeded()
        return cachedLikedIds?.contains(assetId) ?? false
    }

    func setLiked(_ assetId: String, isLiked: Bool) {
        loadIfNeeded()
        if isLiked {
            cachedLikedIds?.insert(assetId)
        } else {
            cachedLikedIds?.remove(assetId)
        }
        saveToDisk()
    }

    func allLikedIds() -> Set<String> {
        loadIfNeeded()
        return cachedLikedIds ?? []
    }

    func clearAll() {
        cachedLikedIds = []
        userDefaults.removeObject(forKey: Keys.likedAssetIds)
    }

    // MARK: - Private
    private func loadIfNeeded() {
        guard cachedLikedIds == nil else { return }
        let array = userDefaults.stringArray(forKey: Keys.likedAssetIds) ?? []
        cachedLikedIds = Set(array)
    }

    private func saveToDisk() {
        guard let ids = cachedLikedIds else { return }
        userDefaults.set(Array(ids), forKey: Keys.likedAssetIds)
    }
}

// MARK: - Mock Implementation
@MainActor
final class MockLikeStorage: LikeStorage {
    private var likedIds: Set<String> = []

    func isLiked(_ assetId: String) -> Bool {
        likedIds.contains(assetId)
    }

    func setLiked(_ assetId: String, isLiked: Bool) {
        if isLiked {
            likedIds.insert(assetId)
        } else {
            likedIds.remove(assetId)
        }
    }

    func allLikedIds() -> Set<String> {
        likedIds
    }

    func clearAll() {
        likedIds.removeAll()
    }
}
