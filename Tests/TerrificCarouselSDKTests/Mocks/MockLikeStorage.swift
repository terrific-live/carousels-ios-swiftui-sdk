//
//  MockLikeStorage.swift
//  TerrificCarouselSDKTests
//

@testable import TerrificCarouselSDK

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
