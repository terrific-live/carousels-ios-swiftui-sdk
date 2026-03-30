//
//  Product.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 10.02.2026.
//

import Foundation

// MARK: - Product
struct ProductDTO: Identifiable, Codable, Equatable, Hashable {
    let id: String?
    let name: String?
    let description: String?
    let externalUrl: String?
    let imageUrl: String?
    let price: Double?
    let formattedPrice: String?
    let compareAtPrice: Double?
    let formattedCompareAtPrice: String?
    let currency: String?
    let externalId: String?
    let sku: String?
    let type: String?
    let categories: [String]?
    let variants: [ProductVariantDTO]?
    let badge: ProductBadgeDTO?
    let ctaButton: ProductCTAButtonDTO?
    let background: ProductBackgroundDTO?

    /// Computed id for Identifiable conformance (falls back to UUID if nil)
    var stableId: String {
        id ?? UUID().uuidString
    }
}

// MARK: - ProductVariant
struct ProductVariantDTO: Codable, Equatable, Hashable {
    let id: String?
    let name: String?
    let price: Double?
    let formattedPrice: String?
    let sku: String?
}

// MARK: - ProductBadge
struct ProductBadgeDTO: Codable, Equatable, Hashable {
    let color: String?
    let text: String?
    let textColor: String?
}

// MARK: - ProductCTAButton
struct ProductCTAButtonDTO: Codable, Equatable, Hashable {
    let color: String?
    let text: String?
    let textColor: String?
}

// MARK: - ProductBackground
struct ProductBackgroundDTO: Codable, Equatable, Hashable {
    let color: String?
    let textColor: String?
}

// MARK: - Product Sample Data
extension ProductDTO {
    /// Full product with all elements
    static let sampleFull = ProductDTO(
        id: "product-1",
        name: "Premium Headphones",
        description: "High-quality wireless headphones with noise cancellation",
        externalUrl: "https://example.com/products/headphones",
        imageUrl: "https://picsum.photos/200?random=10",
        price: 299.99,
        formattedPrice: "299,99 €",
        compareAtPrice: 399.99,
        formattedCompareAtPrice: "399,99 €",
        currency: "EUR",
        externalId: nil,
        sku: "SKU-001",
        type: "custom",
        categories: ["Electronics", "Audio"],
        variants: [],
        badge: ProductBadgeDTO(
            color: "#000E3D",
            text: "Sponsored",
            textColor: "#FFFFFF"
        ),
        ctaButton: ProductCTAButtonDTO(
            color: "#BEF264",
            text: "Buy Now",
            textColor: "#000000"
        ),
        background: ProductBackgroundDTO(
            color: "#D946EF",
            textColor: "#FFFFFF"
        )
    )

    /// Product without badge
    static let sampleNoBadge = ProductDTO(
        id: "product-2",
        name: "Wireless Earbuds",
        description: "Compact earbuds with crystal clear sound",
        externalUrl: "https://example.com/products/earbuds",
        imageUrl: "https://picsum.photos/200?random=11",
        price: 149.50,
        formattedPrice: "149,50 €",
        compareAtPrice: nil,
        formattedCompareAtPrice: nil,
        currency: "EUR",
        externalId: nil,
        sku: nil,
        type: "custom",
        categories: nil,
        variants: [],
        badge: nil,
        ctaButton: ProductCTAButtonDTO(
            color: "#FBBF24",
            text: "Shop",
            textColor: "#000000"
        ),
        background: ProductBackgroundDTO(
            color: "#3B82F6",
            textColor: "#FFFFFF"
        )
    )

    /// Product without CTA button
    static let sampleNoCTA = ProductDTO(
        id: "product-3",
        name: "Smart Watch",
        description: "Track your fitness and stay connected",
        externalUrl: "https://example.com/products/watch",
        imageUrl: "https://picsum.photos/200?random=12",
        price: 399.00,
        formattedPrice: "399,00 €",
        compareAtPrice: nil,
        formattedCompareAtPrice: nil,
        currency: "EUR",
        externalId: nil,
        sku: nil,
        type: "custom",
        categories: nil,
        variants: [],
        badge: ProductBadgeDTO(
            color: "#EF4444",
            text: "New",
            textColor: "#FFFFFF"
        ),
        ctaButton: nil,
        background: ProductBackgroundDTO(
            color: "#10B981",
            textColor: "#FFFFFF"
        )
    )

    /// Product with minimal data
    static let sampleMinimal = ProductDTO(
        id: "product-4",
        name: "USB-C Cable",
        description: "Fast charging cable, 2 meters",
        externalUrl: "https://example.com/products/cable",
        imageUrl: "https://picsum.photos/200?random=13",
        price: 19.99,
        formattedPrice: "19,99 €",
        compareAtPrice: nil,
        formattedCompareAtPrice: nil,
        currency: "EUR",
        externalId: nil,
        sku: nil,
        type: "custom",
        categories: nil,
        variants: [],
        badge: nil,
        ctaButton: nil,
        background: ProductBackgroundDTO(
            color: "#F3F4F6",
            textColor: "#000000"
        )
    )

    /// Product with light background
    static let sampleLightBackground = ProductDTO(
        id: "product-5",
        name: "Laptop Stand",
        description: "Ergonomic aluminum stand for laptops",
        externalUrl: "https://example.com/products/stand",
        imageUrl: "https://picsum.photos/200?random=14",
        price: 79.00,
        formattedPrice: "79,00 €",
        compareAtPrice: nil,
        formattedCompareAtPrice: nil,
        currency: "EUR",
        externalId: nil,
        sku: nil,
        type: "custom",
        categories: nil,
        variants: [],
        badge: ProductBadgeDTO(
            color: "#1F2937",
            text: "Best Seller",
            textColor: "#FFFFFF"
        ),
        ctaButton: ProductCTAButtonDTO(
            color: "#1F2937",
            text: "View Details",
            textColor: "#FFFFFF"
        ),
        background: ProductBackgroundDTO(
            color: "#FEF3C7",
            textColor: "#000000"
        )
    )
}
