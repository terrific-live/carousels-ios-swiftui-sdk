//
//  CarouselItem.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 04.02.2026.
//

import Foundation

// MARK: - CarouselItem
/// A wrapper enum that makes loading state a first-class citizen in carousel data.
/// This ensures the skeleton has a real index, enabling proper selection tracking.
///
/// When user scrolls to skeleton (index N) and new items load:
/// - Before: [item0...item9, .loading] → user on index 10
/// - After:  [item0...item9, item10...item19, .loading] → index 10 = first new item
///
/// Note: Uses index in ID to support duplicate items from backend (looped content).
enum CarouselItem<T>: Identifiable where T: Identifiable, T.ID: CustomStringConvertible {
    case content(T, index: Int)
    case loading

    var id: String {
        switch self {
        case .content(let item, let index):
            return "content-\(index)-\(item.id)"
        case .loading:
            return "loading"
        }
    }

    /// Returns the wrapped content if this is a `.content` case, nil otherwise
    var content: T? {
        if case .content(let item, _) = self {
            return item
        }
        return nil
    }

    /// Returns true if this is the loading placeholder
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
}

// MARK: - Equatable
extension CarouselItem: Equatable where T: Equatable {
    static func == (lhs: CarouselItem<T>, rhs: CarouselItem<T>) -> Bool {
        switch (lhs, rhs) {
        case (.content(let l, let lIndex), .content(let r, let rIndex)):
            return l == r && lIndex == rIndex
        case (.loading, .loading):
            return true
        default:
            return false
        }
    }
}

// MARK: - Hashable
extension CarouselItem: Hashable where T: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .content(let item, let index):
            hasher.combine("content")
            hasher.combine(index)
            hasher.combine(item)
        case .loading:
            hasher.combine("loading")
        }
    }
}

// MARK: - Array Extension
extension Array {
    /// Creates carousel items from content array, appending loading placeholder if needed.
    /// Each item gets a unique index-based ID to support duplicate items from backend.
    static func carouselItems<T>(
        from items: [T],
        hasMorePages: Bool
    ) -> [CarouselItem<T>] where Element == CarouselItem<T> {
        var result = items.enumerated().map { index, item in
            CarouselItem.content(item, index: index)
        }
        if hasMorePages {
            result.append(.loading)
        }
        return result
    }
}
