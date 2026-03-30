//
//  ManualCarouselView.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 20.01.2026.
//

import SwiftUI

struct ScrollViewPeekCarousel<Item: Identifiable, ItemContent: View, LoadingView: View>: View {

    // MARK: - Configuration properties
    @Binding
    var currentPageIndex: Int
    let items: [Item]
    let showLoadingView: Bool
    let peek: CGFloat    // Amount of neighbor to see
    let spacing: CGFloat // Space between cards
    let itemContent: (Item, Bool) -> ItemContent  // Now includes isSelected
    let loadingView: () -> LoadingView
    let onPageChange: ((Int) -> Void)?

    // MARK: - Init
    init(
        currentPageIndex: Binding<Int>,
        items: [Item],
        showLoadingView: Bool = false,
        peek: CGFloat = 60,
        spacing: CGFloat = 20,
        onPageChange: ((Int) -> Void)? = nil,
        @ViewBuilder itemContent: @escaping (Item, Bool) -> ItemContent,
        @ViewBuilder loadingView: @escaping () -> LoadingView
    ) {
        self._currentPageIndex = currentPageIndex
        self.items = items
        self.showLoadingView = showLoadingView
        self.peek = peek
        self.spacing = spacing
        self.onPageChange = onPageChange
        self.itemContent = itemContent
        self.loadingView = loadingView
    }

    // MARK: - State
    @State
    private var scrollPosition: Int?

    var body: some View {
        GeometryReader { geometry in
            // 1. Calculate the exact width the card needs to be
            // So that we have exactly 'peek' amount of space on left/right
            let cardWidth = geometry.size.width - (peek * 2) - (spacing * 2)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: spacing) {
                    buildContent(cardWidth: cardWidth, cardHeight: geometry.size.height)
                }
                // 4. Important: Tell ScrollView these stack items are the snap targets
                .scrollTargetLayout()
            }
            // 5. "Magnet" physics: Snap to the center of the view
            .scrollTargetBehavior(.viewAligned)
            // 6. Bind scroll to your state
            .scrollPosition(id: $scrollPosition)
            // 7. Add padding to the scroll container so the first item can be centered
            // We use 'safeArea' padding to ensure the first item isn't stuck to the left edge
            .contentMargins(.horizontal, peek + spacing, for: .scrollContent)

            // Sync Logic
            .onAppear {
                scrollPosition = currentPageIndex
            }
            .onChange(of: currentPageIndex) { _, newValue in
                withAnimation {
                    scrollPosition = newValue
                }
            }
            .onChange(of: scrollPosition) { _, newValue in
                guard let newValue else { return }

                if currentPageIndex != newValue {
                    currentPageIndex = newValue
                    onPageChange?(newValue)
                }
            }
        }
    }

    @ViewBuilder
    private func buildContent(cardWidth: CGFloat, cardHeight: CGFloat) -> some View {
        ForEach(Array(items.enumerated()), id: \.offset) { index, item in
            let isSelected = index == currentPageIndex
            itemContent(item, isSelected)
                .frame(width: cardWidth, height: cardHeight)
                .scrollTransition(.interactive, axis: .horizontal) { view, phase in
                    view
                        .scaleEffect(phase.isIdentity ? 1.0 : 0.85)
                        .opacity(phase.isIdentity ? 1.0 : 0.6)
                }
                .id(index) // Use integer ID for scroll position binding
        }

        if showLoadingView {
            loadingView()
                .frame(width: cardWidth, height: cardHeight)
                .scrollTransition(.interactive, axis: .horizontal) { view, phase in
                    view
                        .scaleEffect(phase.isIdentity ? 1.0 : 0.85)
                        .opacity(phase.isIdentity ? 1.0 : 0.6)
                }
                .id(items.count) // Loading gets next index after items
        }
    }
}

// MARK: - Convenience Initializer (Without Loading View)
extension ScrollViewPeekCarousel where LoadingView == EmptyView {
    init(
        currentPageIndex: Binding<Int>,
        items: [Item],
        peek: CGFloat = 60,
        spacing: CGFloat = 20,
        onPageChange: ((Int) -> Void)? = nil,
        @ViewBuilder itemContent: @escaping (Item, Bool) -> ItemContent
    ) {
        self._currentPageIndex = currentPageIndex
        self.items = items
        self.showLoadingView = false
        self.peek = peek
        self.spacing = spacing
        self.onPageChange = onPageChange
        self.itemContent = itemContent
        self.loadingView = { EmptyView() }
    }
}
