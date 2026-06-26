//
//  ProductDTO+SampleData.swift
//  TerrificCarouselSDK
//

#if DEBUG

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
        currency: "EUR",
        type: "custom",
        variants: [],
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
        currency: "EUR",
        type: "custom",
        variants: [],
        badge: ProductBadgeDTO(
            color: "#EF4444",
            text: "New",
            textColor: "#FFFFFF"
        ),
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
        currency: "EUR",
        type: "custom",
        variants: [],
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
        currency: "EUR",
        type: "custom",
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

#endif
