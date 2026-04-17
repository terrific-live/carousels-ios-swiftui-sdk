//
//  CarouselAsset.swift
//  CarouselDemo
//
//  Public type representing an asset in the carousel.
//

import Foundation

// MARK: - CarouselAssetType
/// Type of media content in an asset
public enum CarouselAssetType: String, Sendable {
    case image
    case video
    case poll
    case ad
}

// MARK: - CarouselAsset
/// Public representation of an asset in the carousel.
/// Exposed to SDK users for analytics and action callbacks.
public struct CarouselAsset: Identifiable, Sendable {
    /// Unique identifier for the asset
    public let id: String
    /// Display title
    public let title: String?
    /// Description text
    public let description: String?
    /// Type of asset (image, video, poll)
    public let type: CarouselAssetType
    /// Position in the carousel (0-indexed)
    public let position: Int
    /// Timestamp of the asset
    public let timestamp: Date?
    /// Brand name associated with the asset
    public let brandName: String?
    /// Campaign name associated with the asset
    public let campaignName: String?
}

// MARK: - Internal Conversion
extension CarouselAsset {
    /// Creates a CarouselAsset from internal TimelineAssetDTO
    init(from dto: TimelineAssetDTO) {
        self.id = dto.id
        self.title = dto.title
        self.description = dto.description
        self.type = CarouselAssetType(from: dto.type)
        self.position = dto.position
        self.timestamp = dto.timestampDate
        self.brandName = dto.brandName
        self.campaignName = dto.campaignName
    }
}

extension CarouselAssetType {
    init(from dto: AssetMediaTypeDTO) {
        switch dto {
        case .image:
            self = .image
        case .video:
            self = .video
        case .poll:
            self = .poll
        case .ad:
            self = .ad
        }
    }
}

// MARK: - CarouselProduct
/// Public representation of a product in the carousel.
/// Exposed to SDK users for analytics callbacks.
public struct CarouselProduct: Identifiable, Sendable {
    /// Unique identifier for the product
    public let id: String
    /// Product name
    public let name: String?
    /// Product description
    public let description: String?
    /// External URL for the product
    public let externalUrl: String?
    /// Product image URL
    public let imageUrl: String?
    /// Product price (formatted)
    public let price: String?
}

// MARK: - CarouselProduct Internal Conversion
extension CarouselProduct {
    /// Creates a CarouselProduct from internal ProductDTO
    init(from dto: ProductDTO) {
        self.id = dto.id ?? ""
        self.name = dto.name
        self.description = dto.description
        self.externalUrl = dto.externalUrl
        self.imageUrl = dto.imageUrl
        self.price = dto.formattedPrice
    }
}
