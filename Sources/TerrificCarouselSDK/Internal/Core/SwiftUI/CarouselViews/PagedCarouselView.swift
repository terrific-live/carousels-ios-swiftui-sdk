//
//  PagedCarouselView.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 15.01.2026.
//

import SwiftUI

// MARK: - Types
enum PagedCarouselScrollDirection {
    case horizontal
    case vertical
}

// MARK: - PagedCarouselView
/// A paging carousel view that supports both horizontal and vertical scrolling directions.
/// Encapsulates TabView with page style, rotation logic, and handles loading state.
struct PagedCarouselView<Item: Identifiable, ItemContent: View, LoadingView: View>: View {
    
    // MARK: - Configuration properties
    @Binding
    var selection: Int
    let items: [Item]
    let scrollDirection: PagedCarouselScrollDirection
    let showLoadingView: Bool
    let itemContent: (Item, Bool) -> ItemContent  // (item, isSelected)
    let loadingView: () -> LoadingView
    let onPageChange: ((Int) -> Void)?

    // MARK: - Init
    init(
        selection: Binding<Int>,
        items: [Item],
        scrollDirection: PagedCarouselScrollDirection,
        showLoadingView: Bool = false,
        onPageChange: ((Int) -> Void)? = nil,
        @ViewBuilder itemContent: @escaping (Item, Bool) -> ItemContent,
        @ViewBuilder loadingView: @escaping () -> LoadingView
    ) {
        self._selection = selection
        self.items = items
        self.scrollDirection = scrollDirection
        self.showLoadingView = showLoadingView
        self.onPageChange = onPageChange
        self.itemContent = itemContent
        self.loadingView = loadingView
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { proxy in
            let availableSize = proxy.size
            let containerSize = calculateContainerSize(availableSize: availableSize)
            
            TabView(selection: $selection) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    itemContent(item, index == selection)
                        .frame(width: availableSize.width, height: availableSize.height)
                        .rotationEffect(itemCounterRotation)
                        .tag(index)
                }
                
                if showLoadingView {
                    loadingView()
                        .frame(width: availableSize.width, height: availableSize.height)
                        .rotationEffect(itemCounterRotation)
                        .tag(items.count)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(width: containerSize.width, height: containerSize.height)
            .rotationEffect(layoutRotation)
            // Position helps to correctly center view with rotationEffect
            .position(x: availableSize.width / 2, y: availableSize.height / 2)
            .onChange(of: selection) { _, newValue in
                onPageChange?(newValue)
            }
        }
    }
}

// MARK: - Computed properties (Logic)
private extension PagedCarouselView {
    var isVertical: Bool {
        scrollDirection == .vertical
    }

    var layoutRotation: Angle {
        isVertical ? .degrees(90) : .zero
    }

    var itemCounterRotation: Angle {
        isVertical ? .degrees(-90) : .zero
    }

    /// Calculates the container frame dimensions based on scroll direction.
    /// In vertical mode, width and height are swapped to support the 90-degree rotation hack.
    func calculateContainerSize(availableSize: CGSize) -> CGSize {
        if isVertical {
            return CGSize(width: availableSize.height, height: availableSize.width)
        } else {
            return availableSize
        }
    }
}

// MARK: - Convenience Initializer (Without Loading View)
extension PagedCarouselView where LoadingView == EmptyView {
    init(
        selection: Binding<Int>,
        items: [Item],
        scrollDirection: PagedCarouselScrollDirection,
        onPageChange: ((Int) -> Void)? = nil,
        @ViewBuilder itemContent: @escaping (Item, Bool) -> ItemContent
    ) {
        self._selection = selection
        self.items = items
        self.scrollDirection = scrollDirection
        self.showLoadingView = false
        self.onPageChange = onPageChange
        self.itemContent = itemContent
        self.loadingView = { EmptyView() }
    }
}
