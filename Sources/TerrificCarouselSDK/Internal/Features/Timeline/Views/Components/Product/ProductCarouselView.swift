//
//  ProductCarouselView.swift
//  CarouselDemo
//

import SwiftUI

struct ProductCarouselView: View {
    // MARK: - Constants
    private let animationDuration: Double = 0.4
    /// Multiplier for creating pseudo-infinite scroll
    private let infiniteScrollMultiplier = 30

    // MARK: - Inputs
    let products: [ProductData]
    let displayMode: ProductDisplayMode
    let isSelected: Bool
    let autoScrollInterval: TimeInterval
    let sizeConfig: ProductViewSizeConfiguration?
    let onCtaTap: ((URL?) -> Void)?

    // MARK: - Init
    init(
        products: [ProductData],
        displayMode: ProductDisplayMode = .full,
        isSelected: Bool = true,
        autoScrollInterval: TimeInterval = 5.0,
        sizeConfig: ProductViewSizeConfiguration? = nil,
        onCtaTap: ((URL?) -> Void)? = nil
    ) {
        self.products = products
        self.displayMode = displayMode
        self.isSelected = isSelected
        self.autoScrollInterval = autoScrollInterval
        self.sizeConfig = sizeConfig
        self.onCtaTap = onCtaTap
    }

    // MARK: - State
    @State private var currentIndex: Int = 0
    @State private var isAnimating: Bool = false
    @State private var timer: Timer?

    // MARK: - Display Item for unique IDs
    private struct DisplayProduct: Identifiable {
        let id: String
        let index: Int
        let product: ProductData
    }

    // MARK: - Computed Properties
    /// Size configuration based on display mode, or custom config if provided
    private var sizeConfiguration: ProductViewSizeConfiguration {
        sizeConfig ?? (displayMode == .compact ? .feed : .detail)
    }

    /// Expanded products array for pseudo-infinite scroll (products x 20)
    private var expandedProducts: [DisplayProduct] {
        guard products.count > 1 else {
            return products.enumerated().map {
                DisplayProduct(id: "0_\($0)", index: $0, product: $1)
            }
        }

        var result: [DisplayProduct] = []
        for multiplier in 0..<infiniteScrollMultiplier {
            for (index, product) in products.enumerated() {
                let globalIndex = multiplier * products.count + index
                result.append(DisplayProduct(
                    id: "\(multiplier)_\(index)",
                    index: globalIndex,
                    product: product
                ))
            }
        }
        return result
    }

    /// Total count of expanded products
    private var expandedCount: Int {
        products.count > 1 ? products.count * infiniteScrollMultiplier : products.count
    }

    /// Next product index in expanded array
    private var nextIndex: Int {
        (currentIndex + 1) % expandedCount
    }

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            if products.isEmpty {
                EmptyView()
            } else if products.count == 1 {
                // Single product - no carousel needed
                ProductView(
                    viewData: products[0],
                    displayMode: displayMode,
                    sizeConfiguration: sizeConfiguration,
                    onCtaTap: onCtaTap
                )
            } else {
                // Multiple products - carousel (scrollable)
                carouselContent(width: geometry.size.width)
            }
        }
        .frame(height: sizeConfiguration.totalHeight)
        .clipShape(Rectangle()) // Clip at container level to hide next item
        .onAppear {
            if isSelected {
                startTimer()
            }
        }
        .onDisappear {
            stopTimer()
        }
        .onChange(of: isSelected) { _, newValue in
            if newValue {
                startTimer()
            } else {
                stopTimer()
            }
        }
    }
}

// MARK: - Carousel Content
private extension ProductCarouselView {
    func carouselContent(width: CGFloat) -> some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(expandedProducts) { item in
                        ProductView(
                            viewData: item.product,
                            displayMode: displayMode,
                            sizeConfiguration: sizeConfiguration,
                            onCtaTap: onCtaTap
                        )
                        .frame(width: width)
                        .id(item.index)
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .preference(
                                        key: ProductScrollOffsetKey.self,
                                        value: [item.index: geo.frame(in: .named("ProductCarousel")).minX]
                                    )
                            }
                        )
                    }
                }
            }
            .coordinateSpace(name: "ProductCarousel")
            .scrollTargetBehavior(.paging)
            .onPreferenceChange(ProductScrollOffsetKey.self) { offsets in
                updateCurrentIndexFromScroll(offsets, width: width)
            }
            .onChange(of: currentIndex) { oldIndex, newIndex in
                // Only scroll programmatically if this is an auto-scroll (timer-driven)
                // Check if the change is from auto-scroll (sequential increment)
                guard isAnimating else { return }
                withAnimation(.easeInOut(duration: animationDuration)) {
                    proxy.scrollTo(newIndex, anchor: .leading)
                }
            }
        }
    }

    func updateCurrentIndexFromScroll(_ offsets: [Int: CGFloat], width: CGFloat) {
        guard !isAnimating, !offsets.isEmpty else { return }

        // Find the item closest to the leading edge
        let closestItem = offsets.min { abs($0.value) < abs($1.value) }
        guard let (index, offset) = closestItem else { return }

        // Only update when item is settled (within 10% of width)
        guard abs(offset) < width * 0.1 else { return }

        // Update currentIndex to match scroll position
        if currentIndex != index {
            currentIndex = index
        }
    }

    // MARK: - Timer Management
    func startTimer() {
        guard products.count > 1 else { return }
        stopTimer()

        timer = Timer.scheduledTimer(withTimeInterval: autoScrollInterval, repeats: true) { _ in
            DispatchQueue.main.async {
                self.advanceToNext()
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func advanceToNext() {
        guard !isAnimating else { return }
        isAnimating = true

        currentIndex = nextIndex

        // Reset animation flag after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration + 0.05) {
            isAnimating = false
        }
    }
}

// MARK: - Preference Key for Scroll Position
private struct ProductScrollOffsetKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]

    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue()) { _, new in new }
    }
}

// MARK: - Preview
#Preview("Detail Mode") {
    VStack {
        ProductCarouselView(
            products: [
                ProductData(from: .sampleFull),
                ProductData(from: .sampleNoBadge),
                ProductData(from: .sampleNoCTA),
                ProductData(from: .sampleLightBackground)
            ],
            displayMode: .full,
            isSelected: true,
            autoScrollInterval: 2.0
        ) { url in
            print("CTA: \(url?.absoluteString ?? "nil")")
        }
        .padding()

        Spacer()
    }
}

#Preview("Feed Mode") {
    VStack {
        ProductCarouselView(
            products: [
                ProductData(from: .sampleFull),
                ProductData(from: .sampleNoBadge),
                ProductData(from: .sampleMinimal)
            ],
            displayMode: .compact,
            isSelected: true,
            autoScrollInterval: 2.0
        )
        .padding()

        Spacer()
    }
}
