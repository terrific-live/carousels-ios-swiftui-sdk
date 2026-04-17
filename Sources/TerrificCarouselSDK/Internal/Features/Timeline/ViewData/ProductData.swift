//
//  ProductViewData.swift
//  CarouselDemo
//

import SwiftUI

// MARK: - Display Mode
enum ProductDisplayMode {
    case compact
    case full
}

// MARK: - ProductViewData
/// View model for ProductView containing UI-ready data
struct ProductData: Identifiable, Equatable {

    // MARK: - Identity
    let id: String

    // MARK: - Content
    let title: String
    let subtitle: String
    let price: String?
    let imageURL: URL?

    // MARK: - Styling
    let backgroundColor: Color
    let textColor: Color

    let ctaButton: CTAButtonData?
    let sponsorBadge: BadgeData?

    // MARK: - Computed Properties
    /// Secondary text color (for subtitle)
    var secondaryTextColor: Color {
        textColor.opacity(0.9)
    }
}

// MARK: - BadgeData
struct BadgeData: Equatable {
    let text: String
    let backgroundColor: Color
    let textColor: Color
}

// MARK: - Convenience Initializer from Product (Service Model)
extension ProductData {
    init(from product: ProductDTO) {
        self.init(from: product, titleOverride: nil)
    }

    /// Creates ProductData from ProductDTO with optional title override
    /// - Parameters:
    ///   - product: The product DTO
    ///   - titleOverride: Optional title to use instead of product name (e.g., asset brandName)
    init(from product: ProductDTO, titleOverride: String?) {
        self.id = product.stableId
        self.title = titleOverride ?? product.name ?? ""
        self.subtitle = product.description ?? ""
        self.price = product.formattedPrice
        self.imageURL = product.imageUrl.flatMap { URL(string: $0) }

        self.backgroundColor = Color(hex: product.background?.color ?? "#000000")
        self.textColor = Color(hex: product.background?.textColor ?? "#FFFFFF")

        // CTA Button - present if ctaButton exists with text
        if let ctaButton = product.ctaButton, let text = ctaButton.text, !text.isEmpty {
            self.ctaButton = CTAButtonData(
                text: text,
                url: product.externalUrl.flatMap { URL(string: $0) },
                backgroundColor: Color(hex: ctaButton.color ?? "#000000"),
                textColor: Color(hex: ctaButton.textColor ?? "#000000")
            )
        } else {
            self.ctaButton = nil
        }

        // Badge - present if badge exists with text
        if let badge = product.badge, let text = badge.text, !text.isEmpty {
            self.sponsorBadge = BadgeData(
                text: text,
                backgroundColor: Color(hex: badge.color ?? "#000000"),
                textColor: Color(hex: badge.textColor ?? "#FFFFFF")
            )
        } else {
            self.sponsorBadge = nil
        }
    }
}
