//
//  Product.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 10.02.2026.
//

import Foundation

// MARK: - Product
struct ProductDTO: Identifiable, Codable, Equatable, Hashable {
    let id: String
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

    init(
        id: String,
        name: String? = nil,
        description: String? = nil,
        externalUrl: String? = nil,
        imageUrl: String? = nil,
        price: Double? = nil,
        formattedPrice: String? = nil,
        compareAtPrice: Double? = nil,
        formattedCompareAtPrice: String? = nil,
        currency: String? = nil,
        externalId: String? = nil,
        sku: String? = nil,
        type: String? = nil,
        categories: [String]? = nil,
        variants: [ProductVariantDTO]? = nil,
        badge: ProductBadgeDTO? = nil,
        ctaButton: ProductCTAButtonDTO? = nil,
        background: ProductBackgroundDTO? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.externalUrl = externalUrl
        self.imageUrl = imageUrl
        self.price = price
        self.formattedPrice = formattedPrice
        self.compareAtPrice = compareAtPrice
        self.formattedCompareAtPrice = formattedCompareAtPrice
        self.currency = currency
        self.externalId = externalId
        self.sku = sku
        self.type = type
        self.categories = categories
        self.variants = variants
        self.badge = badge
        self.ctaButton = ctaButton
        self.background = background
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.externalUrl = try container.decodeIfPresent(String.self, forKey: .externalUrl)
        self.imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        self.price = try container.decodeIfPresent(Double.self, forKey: .price)
        self.formattedPrice = try container.decodeIfPresent(String.self, forKey: .formattedPrice)
        self.compareAtPrice = try container.decodeIfPresent(Double.self, forKey: .compareAtPrice)
        self.formattedCompareAtPrice = try container.decodeIfPresent(String.self, forKey: .formattedCompareAtPrice)
        self.currency = try container.decodeIfPresent(String.self, forKey: .currency)
        self.externalId = try container.decodeIfPresent(String.self, forKey: .externalId)
        self.sku = try container.decodeIfPresent(String.self, forKey: .sku)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.categories = try container.decodeIfPresent([String].self, forKey: .categories)
        self.variants = try container.decodeIfPresent([ProductVariantDTO].self, forKey: .variants)
        self.badge = try container.decodeIfPresent(ProductBadgeDTO.self, forKey: .badge)
        self.ctaButton = try container.decodeIfPresent(ProductCTAButtonDTO.self, forKey: .ctaButton)
        self.background = try container.decodeIfPresent(ProductBackgroundDTO.self, forKey: .background)
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
