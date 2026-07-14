//
//  CarouselVisibilityCalculator.swift
//  TerrificCarouselSDK
//

import SwiftUI

// MARK: - CarouselVisibilityCalculator
/// Pure logic for determining which carousel item is most visible.
enum CarouselVisibilityCalculator {

    /// Returns the index that should be selected based on item visibilities.
    /// - Returns: The new index if selection should change, or `nil` if current selection should be kept.
    static func resolveSelectedIndex(
        visibilities: [Int: CGFloat],
        currentIndex: Int
    ) -> Int? {
        // Find the maximum visible width
        guard let maxVisibility = visibilities.values.max(),
              maxVisibility > 0 else {
            return nil
        }

        // If the current selection is fully (or nearly fully) visible, keep it.
        // This prevents arbitrary jumps when multiple items are equally visible (e.g. iPad).
        let currentVisibility = visibilities[currentIndex] ?? 0
        if currentVisibility >= maxVisibility * 0.95 {
            return nil
        }

        // Pick the lowest index among equally most-visible items
        guard let mostVisibleIndex = visibilities
            .filter({ $0.value >= maxVisibility * 0.95 })
            .min(by: { $0.key < $1.key })?
            .key
        else { return nil }

        // Only return if selection actually changed
        guard currentIndex != mostVisibleIndex else { return nil }

        return mostVisibleIndex
    }
}

// MARK: - VisibilityReporter
/// Reports the visible width of an item within a named coordinate space.
struct VisibilityReporter: View {
    let index: Int
    let coordinateSpace: String
    let containerWidth: CGFloat

    var body: some View {
        GeometryReader { geometry in
            let frame = geometry.frame(in: .named(coordinateSpace))
            let visibleWidth = Self.calculateVisibleWidth(itemFrame: frame, containerWidth: containerWidth)

            Color.clear
                .preference(
                    key: ItemVisibilityPreferenceKey.self,
                    value: [index: visibleWidth]
                )
        }
    }

    static func calculateVisibleWidth(itemFrame: CGRect, containerWidth: CGFloat) -> CGFloat {
        let visibleLeft = max(itemFrame.minX, 0)
        let visibleRight = min(itemFrame.maxX, containerWidth)
        return max(0, visibleRight - visibleLeft)
    }
}

// MARK: - ItemVisibilityPreferenceKey
struct ItemVisibilityPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]

    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue()) { _, new in new }
    }
}
