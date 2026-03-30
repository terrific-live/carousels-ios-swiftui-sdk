//
//  ProductCarouselView.swift
//  CarouselDemo
//

import SwiftUI

struct ProductCarouselView: View {
    // MARK: - Constants
    private let animationDuration: Double = 0.4

    // MARK: - Inputs
    let products: [ProductData]
    let displayMode: ProductDisplayMode
    let isSelected: Bool
    let autoScrollInterval: TimeInterval
    let onCtaTap: ((URL?) -> Void)?

    // MARK: - Init
    init(
        products: [ProductData],
        displayMode: ProductDisplayMode = .full,
        isSelected: Bool = true,
        autoScrollInterval: TimeInterval = 5.0,
        onCtaTap: ((URL?) -> Void)? = nil
    ) {
        self.products = products
        self.displayMode = displayMode
        self.isSelected = isSelected
        self.autoScrollInterval = autoScrollInterval
        self.onCtaTap = onCtaTap
    }

    // MARK: - State
    @State private var currentIndex: Int = 0
    @State private var isAnimating: Bool = false
    @State private var timer: Timer?

    // MARK: - Computed Properties
    /// Size configuration based on display mode
    private var sizeConfiguration: ProductViewSizeConfiguration {
        displayMode == .compact ? .feed : .detail
    }

    /// Next product index (wraps around)
    private var nextIndex: Int {
        (currentIndex + 1) % products.count
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
                    ForEach(products) { product in
                        ProductView(
                            viewData: product,
                            displayMode: displayMode,
                            onCtaTap: onCtaTap
                        )
                        .frame(width: width)
                        .id(product.id)
                    }
                }
            }
            .scrollTargetBehavior(.paging)
            .onChange(of: currentIndex) { _, newIndex in
                withAnimation(.easeInOut(duration: animationDuration)) {
                    proxy.scrollTo(products[newIndex].id, anchor: .leading)
                }
            }
        }
    }

    // MARK: - Timer Management
    func startTimer() {
        guard products.count > 1 else { return }

        timer = Timer.scheduledTimer(withTimeInterval: autoScrollInterval, repeats: true) { _ in
            advanceToNext()
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
