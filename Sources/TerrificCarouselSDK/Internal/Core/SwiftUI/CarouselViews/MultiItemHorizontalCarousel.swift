//
//  MultiItemHorizontalCarousel.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 27.03.2026.
//

import SwiftUI
import UIKit

// MARK: - PageScrollDirection
enum PageScrollDirection: Equatable {
    case forward
    case backward
}

// MARK: - MultiItemHorizontalCarousel
/// A horizontal carousel that shows multiple items at once.
/// The item with the most visible area is considered "selected".
/// Unlike ScrollViewPeekCarousel, this doesn't center the selected item.
struct MultiItemHorizontalCarousel<Item: Identifiable, ItemContent: View, LoadingView: View>: View {

    // MARK: - Configuration properties
    @Binding
    var currentPageIndex: Int
    /// When set, scrolls one page forward or backward, then resets to nil.
    @Binding
    var pageScrollDirection: PageScrollDirection?
    let items: [Item]
    let showLoadingView: Bool
    let itemWidth: CGFloat
    let itemHeight: CGFloat?
    let spacing: CGFloat
    let horizontalPadding: CGFloat
    /// Content builder: (item, isSelected, index, totalCount) -> View
    let itemContent: (Item, Bool, Int, Int) -> ItemContent
    let loadingView: () -> LoadingView
    let onPageChange: ((Int) -> Void)?

    // MARK: - State
    @State
    private var itemVisibilities: [Int: CGFloat] = [:]
    /// Tracks if scroll is happening from programmatic change (vs user swipe)
    @State
    private var isProgrammaticScroll: Bool = false
    /// Tracks VoiceOver focus so it survives view re-renders triggered by currentPageIndex changes
    @AccessibilityFocusState
    private var accessibilityFocusedIndex: Int?

    // MARK: - Init
    init(
        currentPageIndex: Binding<Int>,
        pageScrollDirection: Binding<PageScrollDirection?> = .constant(nil),
        items: [Item],
        showLoadingView: Bool = false,
        itemWidth: CGFloat = 280,
        itemHeight: CGFloat? = nil,
        spacing: CGFloat = 12,
        horizontalPadding: CGFloat = 16,
        onPageChange: ((Int) -> Void)? = nil,
        @ViewBuilder itemContent: @escaping (Item, Bool, Int, Int) -> ItemContent,
        @ViewBuilder loadingView: @escaping () -> LoadingView
    ) {
        self._currentPageIndex = currentPageIndex
        self._pageScrollDirection = pageScrollDirection
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
            ScrollViewReader { proxy in
                if #available(iOS 17, macOS 14, tvOS 17, *) {
                    scrollContent(containerWidth: geometry.size.width)
                        .onChange(of: currentPageIndex) { _, newValue in
                            handlePageIndexScroll(to: newValue, proxy: proxy)
                        }
                        .onChange(of: pageScrollDirection) { _, newValue in
                            handlePageScroll(direction: newValue, proxy: proxy, containerWidth: geometry.size.width)
                        }
                } else {
                    // iOS16-COMPAT: Remove when minimum target is iOS 17
                    scrollContent(containerWidth: geometry.size.width)
                        .onChange(of: currentPageIndex) { newValue in
                            handlePageIndexScroll(to: newValue, proxy: proxy)
                        }
                        .onChange(of: pageScrollDirection) { newValue in
                            handlePageScroll(direction: newValue, proxy: proxy, containerWidth: geometry.size.width)
                        }
                }
            }
        }
    }

    // MARK: - Page Scroll

    private func handlePageScroll(direction: PageScrollDirection?, proxy: ScrollViewProxy, containerWidth: CGFloat) {
        guard let direction else { return }

        let visibleCount = Self.visibleItemCount(
            containerWidth: containerWidth,
            itemWidth: itemWidth,
            spacing: spacing,
            horizontalPadding: horizontalPadding
        )

        // Find the first item that is at least half visible
        let visibleIndices = itemVisibilities
            .filter { $0.value > itemWidth * 0.5 }
            .map(\.key)
            .sorted()

        let firstVisible = visibleIndices.first ?? currentPageIndex

        let targetIndex: Int
        switch direction {
        case .forward:
            // Scroll so the first currently-invisible item is at the leading edge
            let lastVisible = visibleIndices.last ?? currentPageIndex
            targetIndex = min(items.count - 1, lastVisible + 1)
        case .backward:
            // Scroll back by one page worth of items
            targetIndex = max(0, firstVisible - visibleCount)
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            proxy.scrollTo(targetIndex, anchor: .leading)
        }
        pageScrollDirection = nil
    }

    static func visibleItemCount(
        containerWidth: CGFloat,
        itemWidth: CGFloat,
        spacing: CGFloat,
        horizontalPadding: CGFloat
    ) -> Int {
        let available = containerWidth - 2 * horizontalPadding
        let slot = itemWidth + spacing
        return max(1, Int(floor((available + spacing) / slot)))
    }

    private func scrollContent(containerWidth: CGFloat) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .top, spacing: spacing) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    let isSelected = index == currentPageIndex

                    itemContent(item, isSelected, index, items.count)
                        .frame(width: itemWidth, height: itemHeight)
                        .id(index)
                        .accessibilityFocused($accessibilityFocusedIndex, equals: index)
                        .background(
                            VisibilityReporter(
                                index: index,
                                coordinateSpace: "MultiItemCarouselSpace",
                                containerWidth: containerWidth
                            )
                        )
                }

                if showLoadingView {
                    loadingView()
                        .frame(width: itemWidth, height: itemHeight)
                        .id(items.count)
                        .background(
                            VisibilityReporter(
                                index: items.count,
                                coordinateSpace: "MultiItemCarouselSpace",
                                containerWidth: containerWidth
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

    private func handlePageIndexScroll(to newValue: Int, proxy: ScrollViewProxy) {
        // Only scroll programmatically if this is an external change
        // (not from user scrolling which already updates visibility)
        guard !isProgrammaticScroll else {
            isProgrammaticScroll = false
            return
        }

        // Check if the item is already mostly visible
        let targetVisibility = itemVisibilities[newValue] ?? 0
        let isAlreadyVisible = targetVisibility > itemWidth * 0.8

        guard !isAlreadyVisible else { return }

        withAnimation(.easeInOut(duration: 0.3)) {
            proxy.scrollTo(newValue, anchor: .center)
        }
    }

    // MARK: - Selection Logic
    private func handleVisibilityUpdate(_ visibilities: [Int: CGFloat]) {
        itemVisibilities = visibilities

        guard let mostVisibleIndex = CarouselVisibilityCalculator.resolveSelectedIndex(
            visibilities: visibilities,
            currentIndex: currentPageIndex
        ) else { return }

        // When VoiceOver is active, skip updating the currentPageIndex binding.
        // The binding propagates to a @Published property on the parent view model,
        // triggering a full re-render of the parent view. LazyHStack rebuilds its
        // accessibility tree during re-render, causing VoiceOver to lose focus and
        // jump to the first element in the window.
        // We still fire onPageChange for analytics tracking.
        if UIAccessibility.isVoiceOverRunning {
            onPageChange?(mostVisibleIndex)
            return
        }

        isProgrammaticScroll = true
        currentPageIndex = mostVisibleIndex
        onPageChange?(mostVisibleIndex)
    }
}

// MARK: - Convenience Initializer (Without Loading View)
extension MultiItemHorizontalCarousel where LoadingView == EmptyView {
    init(
        currentPageIndex: Binding<Int>,
        pageScrollDirection: Binding<PageScrollDirection?> = .constant(nil),
        items: [Item],
        itemWidth: CGFloat = 280,
        itemHeight: CGFloat? = nil,
        spacing: CGFloat = 12,
        horizontalPadding: CGFloat = 16,
        onPageChange: ((Int) -> Void)? = nil,
        @ViewBuilder itemContent: @escaping (Item, Bool, Int, Int) -> ItemContent
    ) {
        self._currentPageIndex = currentPageIndex
        self._pageScrollDirection = pageScrollDirection
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
                ) { item, isSelected, _, _ in
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
