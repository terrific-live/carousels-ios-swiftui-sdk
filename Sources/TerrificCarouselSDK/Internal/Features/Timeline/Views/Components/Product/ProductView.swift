//
//  ProductView.swift
//  CarouselDemo
//

import SwiftUI
import ImageLoader

struct ProductView: View {

    // MARK: - Inputs
    let viewData: ProductData
    let displayMode: ProductDisplayMode
    let sizeConfiguration: ProductViewSizeConfiguration
    let onCtaTap: ((ProductData, URL?) -> Void)?

    // MARK: - Init
    init(
        viewData: ProductData,
        displayMode: ProductDisplayMode = .full,
        sizeConfiguration: ProductViewSizeConfiguration? = nil,
        onCtaTap: ((ProductData, URL?) -> Void)? = nil
    ) {
        self.viewData = viewData
        self.displayMode = displayMode
        // Use provided configuration or default based on display mode
        self.sizeConfiguration = sizeConfiguration ?? (displayMode == .compact ? .feed : .detail)
        self.onCtaTap = onCtaTap
    }

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            HStack(alignment: .center, spacing: 0) {
                productImage
                    .padding(.vertical, sizeConfiguration.verticalPadding)
                    .padding(.trailing, sizeConfiguration.imageTrailingPadding)

                content

                Spacer(minLength: 0)
            }
            .padding(.horizontal, sizeConfiguration.horizontalPadding)

            // Floating CTA Button (detail mode only) - pinned to bottom trailing
            if displayMode == .full, let cta = viewData.ctaButton {
                ctaButton(cta)
                    .padding(.trailing, sizeConfiguration.horizontalPadding)
                    .padding(.bottom, sizeConfiguration.verticalPadding)
            }
        }
        .frame(height: sizeConfiguration.totalHeight)
        .background(viewData.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: sizeConfiguration.cornerRadius))
    }

    private var productImage: some View {
        CachedAsyncImage(url: viewData.imageURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: sizeConfiguration.imageSize, height: sizeConfiguration.imageSize)
                .clipped()
        } placeholder: {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: sizeConfiguration.imageSize, height: sizeConfiguration.imageSize)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: sizeConfiguration.imageCornerRadius))
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: sizeConfiguration.interItemVerticalSpacing) {
            Text(viewData.title)
                .font(.system(size: sizeConfiguration.titleFontSize, weight: .bold))
                .foregroundColor(viewData.textColor)
                .lineLimit(1)

            Text(viewData.subtitle)
                .font(.system(size: sizeConfiguration.subtitleFontSize))
                .foregroundColor(viewData.secondaryTextColor)
                .lineLimit(1)

            // Bottom row: Price + Badge
            bottomRow
                .padding(.top, sizeConfiguration.interItemVerticalSpacing)
        }
    }

    @ViewBuilder
    private var bottomRow: some View {
        HStack(alignment: .bottom, spacing: 8) {
            VStack(alignment: .leading, spacing: sizeConfiguration.interItemVerticalSpacing) {
                // Price (detail mode only)
                if displayMode == .full, let price = viewData.price {
                    Text(price)
                        .font(.system(size: sizeConfiguration.priceFontSize, weight: .bold))
                        .foregroundColor(viewData.textColor)
                        .lineLimit(1)
                }

                // Sponsor Badge
                if let badge = viewData.sponsorBadge {
                    badgeView(badge)
                }
            }

            Spacer()
        }
    }

    private func badgeView(_ badge: BadgeData) -> some View {
        Text(badge.text)
            .font(.system(size: sizeConfiguration.badgeFontSize, weight: .medium))
            .foregroundColor(badge.textColor)
            .padding(.horizontal, sizeConfiguration.badgeHorizontalPadding)
            .padding(.vertical, sizeConfiguration.badgeVerticalPadding)
            .background(badge.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: sizeConfiguration.badgeCornerRadius))
    }

    private func ctaButton(_ cta: CTAButtonData) -> some View {
        Button(action: {
            onCtaTap?(viewData, cta.url)
        }) {
            Text(cta.text)
                .font(.system(size: sizeConfiguration.ctaFontSize, weight: .semibold))
                .foregroundColor(cta.textColor)
                .padding(.horizontal, sizeConfiguration.ctaHorizontalPadding)
                .padding(.vertical, sizeConfiguration.ctaVerticalPadding)
                .background(cta.backgroundColor)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Preview
#Preview("Detail Mode - Full") {
    ProductView(
        viewData: ProductData(from: .sampleFull),
        displayMode: .full
    ) { product, url in
        print("CTA tapped: product=\(product.id), url=\(url?.absoluteString ?? "nil")")
    }
    .padding()
}

#Preview("Detail Mode - No Badge") {
    ProductView(
        viewData: ProductData(from: .sampleNoBadge),
        displayMode: .full
    )
    .padding()
}

#Preview("Detail Mode - No CTA") {
    ProductView(
        viewData: ProductData(from: .sampleNoCTA),
        displayMode: .full
    )
    .padding()
}

#Preview("Detail Mode - Light Background") {
    ProductView(
        viewData: ProductData(from: .sampleLightBackground),
        displayMode: .full
    )
    .padding()
}

#Preview("Feed Mode - Full") {
    ProductView(
        viewData: ProductData(from: .sampleFull),
        displayMode: .compact
    )
    .padding()
}

#Preview("Feed Mode - Minimal") {
    ProductView(
        viewData: ProductData(from: .sampleMinimal),
        displayMode: .compact
    )
    .padding()
}
