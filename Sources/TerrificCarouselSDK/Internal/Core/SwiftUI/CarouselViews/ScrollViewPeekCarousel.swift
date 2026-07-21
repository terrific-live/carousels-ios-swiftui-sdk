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
    @State private var scrollPosition: Int?
    // iOS16-COMPAT: Remove when minimum target is iOS 17
    @State private var dragOffset: CGFloat = 0

    // MARK: - Body
    var body: some View {
        if #available(iOS 17, macOS 14, tvOS 17, *) {
            iOS17Body
        } else {
            // iOS16-COMPAT: Remove when minimum target is iOS 17
            iOS16Body
        }
    }
}

// MARK: - iOS 17 Implementation
@available(iOS 17, macOS 14, tvOS 17, *)
private extension ScrollViewPeekCarousel {

    var iOS17Body: some View {
        GeometryReader { geometry in
            let cardWidth = geometry.size.width - (peek * 2) - (spacing * 2)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: spacing) {
                    iOS17Content(cardWidth: cardWidth, cardHeight: geometry.size.height)
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $scrollPosition)
            .contentMargins(.horizontal, peek + spacing, for: .scrollContent)
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
    func iOS17Content(cardWidth: CGFloat, cardHeight: CGFloat) -> some View {
        ForEach(Array(items.enumerated()), id: \.offset) { index, item in
            let isSelected = index == currentPageIndex
            itemContent(item, isSelected)
                .frame(width: cardWidth, height: cardHeight)
                .scrollTransition(.interactive, axis: .horizontal) { view, phase in
                    view
                        .scaleEffect(phase.isIdentity ? 1.0 : 0.85)
                        .opacity(phase.isIdentity ? 1.0 : 0.6)
                }
                .id(index)
        }

        if showLoadingView {
            loadingView()
                .frame(width: cardWidth, height: cardHeight)
                .scrollTransition(.interactive, axis: .horizontal) { view, phase in
                    view
                        .scaleEffect(phase.isIdentity ? 1.0 : 0.85)
                        .opacity(phase.isIdentity ? 1.0 : 0.6)
                }
                .id(items.count)
        }
    }
}

// MARK: - iOS 16 Implementation
// iOS16-COMPAT: Remove this extension when minimum target is iOS 17
private extension ScrollViewPeekCarousel {

    var iOS16Body: some View {
        GeometryReader { geometry in
            let cardWidth = geometry.size.width - (peek * 2) - (spacing * 2)
            let stride = cardWidth + spacing
            let totalItems = items.count + (showLoadingView ? 1 : 0)
            let offset = (peek + spacing) - CGFloat(currentPageIndex) * stride + dragOffset

            HStack(spacing: spacing) {
                iOS16Content(cardWidth: cardWidth, cardHeight: geometry.size.height, stride: stride)
            }
            .offset(x: offset)
            .gesture(iOS16DragGesture(stride: stride, totalItems: totalItems))
            .animation(.interactiveSpring(), value: currentPageIndex)
            .onChange(of: currentPageIndex) { _ in
                dragOffset = 0
            }
        }
        .clipped()
    }

    @ViewBuilder
    func iOS16Content(cardWidth: CGFloat, cardHeight: CGFloat, stride: CGFloat) -> some View {
        ForEach(Array(items.enumerated()), id: \.offset) { index, item in
            let isSelected = index == currentPageIndex
            let transform = iOS16Transform(for: index, stride: stride)
            itemContent(item, isSelected)
                .frame(width: cardWidth, height: cardHeight)
                .scaleEffect(transform.scale)
                .opacity(transform.opacity)
                .id(index)
        }

        if showLoadingView {
            let transform = iOS16Transform(for: items.count, stride: stride)
            loadingView()
                .frame(width: cardWidth, height: cardHeight)
                .scaleEffect(transform.scale)
                .opacity(transform.opacity)
                .id(items.count)
        }
    }

    func iOS16Transform(for index: Int, stride: CGFloat) -> (scale: CGFloat, opacity: CGFloat) {
        let itemDistance = CGFloat(index - currentPageIndex) * stride + dragOffset
        let normalizedDistance = min(abs(itemDistance) / stride, 1.0)
        return (
            scale: 1.0 - (0.15 * normalizedDistance),
            opacity: 1.0 - (0.4 * normalizedDistance)
        )
    }

    func iOS16DragGesture(stride: CGFloat, totalItems: Int) -> some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation.width
            }
            .onEnded { value in
                let predicted = value.predictedEndTranslation.width
                let pageShift = -Int(round(predicted / stride))
                let newIndex = max(0, min(totalItems - 1, currentPageIndex + pageShift))
                let pageChanged = currentPageIndex != newIndex
                withAnimation(.interactiveSpring()) {
                    currentPageIndex = newIndex
                    dragOffset = 0
                }
                if pageChanged {
                    onPageChange?(newIndex)
                }
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
