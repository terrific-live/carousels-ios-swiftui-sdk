//
//  MultiItemHorizontalCarousel.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 27.03.2026.
//

import SwiftUI

// MARK: - MultiItemHorizontalCarousel
/// A horizontal carousel that shows multiple items at once.
/// The item with the most visible area is considered "selected".
/// Unlike ScrollViewPeekCarousel, this doesn't center the selected item.
struct MultiItemHorizontalCarousel<Item: Identifiable, ItemContent: View, LoadingView: View>: View {

    // MARK: - Configuration properties
    @Binding
    var currentPageIndex: Int
    let items: [Item]
    let showLoadingView: Bool
    let itemWidth: CGFloat
    let itemHeight: CGFloat?
    let spacing: CGFloat
    let horizontalPadding: CGFloat
    let itemContent: (Item, Bool) -> ItemContent
    let loadingView: () -> LoadingView
    let onPageChange: ((Int) -> Void)?

    // MARK: - State
    @State
    private var itemVisibilities: [Int: CGFloat] = [:]

    // MARK: - Init
    init(
        currentPageIndex: Binding<Int>,
        items: [Item],
        showLoadingView: Bool = false,
        itemWidth: CGFloat = 280,
        itemHeight: CGFloat? = nil,
        spacing: CGFloat = 12,
        horizontalPadding: CGFloat = 16,
        onPageChange: ((Int) -> Void)? = nil,
        @ViewBuilder itemContent: @escaping (Item, Bool) -> ItemContent,
        @ViewBuilder loadingView: @escaping () -> LoadingView
    ) {
        self._currentPageIndex = currentPageIndex
        self.items = items
        self.showLoadingView = showLoadingView
        self.itemWidth = itemWidth
        self.itemHeight = itemHeight
        self.spacing = spacing
        self.horizontalPadding = horizontalPadding
        self.onPageChange = onPageChange
        self.itemContent = itemContent
        self.loadingView = loadingView
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: spacing) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        let isSelected = index == currentPageIndex

                        itemContent(item, isSelected)
                            .frame(width: itemWidth, height: itemHeight)
                            .background(
                                VisibilityReporter(
                                    index: index,
                                    coordinateSpace: "MultiItemCarouselSpace",
                                    containerWidth: geometry.size.width
                                )
                            )
                    }

                    if showLoadingView {
                        loadingView()
                            .frame(width: itemWidth, height: itemHeight)
                            .background(
                                VisibilityReporter(
                                    index: items.count,
                                    coordinateSpace: "MultiItemCarouselSpace",
                                    containerWidth: geometry.size.width
                                )
                            )
                    }
                }
                .padding(.horizontal, horizontalPadding)
            }
            .coordinateSpace(name: "MultiItemCarouselSpace")
            .onPreferenceChange(ItemVisibilityPreferenceKey.self) { visibilities in
                handleVisibilityUpdate(visibilities)
            }
        }
    }

    // MARK: - Selection Logic
    private func handleVisibilityUpdate(_ visibilities: [Int: CGFloat]) {
        // Store current visibilities
        itemVisibilities = visibilities

        // Find the item with the most visible width
        guard let mostVisibleEntry = visibilities.max(by: { $0.value < $1.value }),
              mostVisibleEntry.value > 0 else {
            return
        }

        let mostVisibleIndex = mostVisibleEntry.key

        // Only update if selection changed
        guard currentPageIndex != mostVisibleIndex else { return }

        currentPageIndex = mostVisibleIndex
        onPageChange?(mostVisibleIndex)
    }
}

// MARK: - Visibility Reporter
/// Reports the visible width of an item within the container
private struct VisibilityReporter: View {
    let index: Int
    let coordinateSpace: String
    let containerWidth: CGFloat

    var body: some View {
        GeometryReader { geometry in
            let frame = geometry.frame(in: .named(coordinateSpace))
            let visibleWidth = calculateVisibleWidth(itemFrame: frame)

            Color.clear
                .preference(
                    key: ItemVisibilityPreferenceKey.self,
                    value: [index: visibleWidth]
                )
        }
    }

    private func calculateVisibleWidth(itemFrame: CGRect) -> CGFloat {
        let itemLeft = itemFrame.minX
        let itemRight = itemFrame.maxX

        // Calculate visible portion within container bounds (0 to containerWidth)
        let visibleLeft = max(itemLeft, 0)
        let visibleRight = min(itemRight, containerWidth)
        let visibleWidth = max(0, visibleRight - visibleLeft)

        return visibleWidth
    }
}

// MARK: - Preference Key for Item Visibility
private struct ItemVisibilityPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]

    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue()) { _, new in new }
    }
}

// MARK: - Convenience Initializer (Without Loading View)
extension MultiItemHorizontalCarousel where LoadingView == EmptyView {
    init(
        currentPageIndex: Binding<Int>,
        items: [Item],
        itemWidth: CGFloat = 280,
        itemHeight: CGFloat? = nil,
        spacing: CGFloat = 12,
        horizontalPadding: CGFloat = 16,
        onPageChange: ((Int) -> Void)? = nil,
        @ViewBuilder itemContent: @escaping (Item, Bool) -> ItemContent
    ) {
        self._currentPageIndex = currentPageIndex
        self.items = items
        self.showLoadingView = false
        self.itemWidth = itemWidth
        self.itemHeight = itemHeight
        self.spacing = spacing
        self.horizontalPadding = horizontalPadding
        self.onPageChange = onPageChange
        self.itemContent = itemContent
        self.loadingView = { EmptyView() }
    }
}

// MARK: - Preview
#Preview {
    struct PreviewItem: Identifiable {
        let id: Int
        let title: String
        let color: Color
    }

    struct PreviewWrapper: View {
        @State private var selectedIndex = 0

        let items = [
            PreviewItem(id: 0, title: "Item 1", color: .red),
            PreviewItem(id: 1, title: "Item 2", color: .blue),
            PreviewItem(id: 2, title: "Item 3", color: .green),
            PreviewItem(id: 3, title: "Item 4", color: .orange),
            PreviewItem(id: 4, title: "Item 5", color: .purple)
        ]

        var body: some View {
            VStack {
                Text("Selected: \(selectedIndex)")
                    .font(.headline)
                    .padding()

                MultiItemHorizontalCarousel(
                    currentPageIndex: $selectedIndex,
                    items: items,
                    itemWidth: 300,
                    spacing: 12,
                    horizontalPadding: 16,
                    onPageChange: { index in
                        print("Page changed to: \(index)")
                    }
                ) { item, isSelected in
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(item.color)
                            .frame(height: 400)
                            .overlay(
                                VStack {
                                    Text(item.title)
                                        .foregroundColor(.white)
                                        .font(.headline)
                                    if isSelected {
                                        Text("SELECTED")
                                            .foregroundColor(.yellow)
                                            .font(.caption)
                                            .fontWeight(.bold)
                                    }
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 3)
                            )

                        Text(item.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Text("Description text goes here")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(height: 480)
            }
            .background(Color.black.opacity(0.9))
        }
    }

    return PreviewWrapper()
}
