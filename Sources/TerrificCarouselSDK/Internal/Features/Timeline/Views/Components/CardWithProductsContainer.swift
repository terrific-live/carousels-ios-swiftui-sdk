//
//  CardWithProductsContainer.swift
//  TerrificCarouselSDK
//

import SwiftUI

// MARK: - CardWithProductsContainer
/// Shared container used by both Feed and Detail asset cards.
/// Renders card content on top with an optional product carousel below.
struct CardWithProductsContainer<CardContent: View>: View {
    let products: [ProductData]
    let displayMode: ProductDisplayMode
    let isSelected: Bool
    let productSizeConfig: ProductViewSizeConfiguration?
    let spacing: CGFloat
    let onProductCtaTap: ((ProductData, URL?) -> Void)?
    @ViewBuilder let cardContent: () -> CardContent

    var body: some View {
        VStack(spacing: spacing) {
            cardContent()

            if !products.isEmpty {
                ProductCarouselView(
                    products: products,
                    displayMode: displayMode,
                    isSelected: isSelected,
                    sizeConfig: productSizeConfig,
                    onCtaTap: onProductCtaTap
                )
            }
        }
    }
}
