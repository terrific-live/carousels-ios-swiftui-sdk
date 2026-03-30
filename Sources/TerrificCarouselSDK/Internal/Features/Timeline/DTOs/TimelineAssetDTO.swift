//
//  TimelineAssetDTO.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 14.01.2026.
//

import Foundation
import ImageLoader

// MARK: - TimelineResponseDTO
/// Root response object from timeline API
struct TimelineResponseDTO: Codable, Equatable {
    let assets: [TimelineAssetDTO]
    let carouselConfig: CarouselConfigDTO?
}

// MARK: - TimelineAssetDTO
struct TimelineAssetDTO: Identifiable, Codable, Equatable, Hashable {
    /// Unique identifier for the asset
    let id: String
    /// Asset name (internal/filename)
    let name: String?
    /// Display title (shown to user)
    let title: String?
    /// Description text
    let description: String?
    /// Media type (video, image, poll)
    let type: AssetMediaTypeDTO
    /// Position in the timeline
    let position: Int
    /// Timestamp (ISO8601 string)
    let timestamp: String?
    /// Media URLs (cover, mobile, desktop, preview) - can be null for polls
    let media: AssetMediaDTO?
    /// Background configuration (can be null)
    let background: AssetBackgroundDTO?
    /// Brand logo (can be null)
    let brandLogo: BrandLogoDTO?
    /// CTA button configuration
    let ctaButton: AssetCTAButtonDTO?
    /// Products associated with this asset
    let products: [ProductDTO]?
    /// Poll data (for poll type assets)
    let pollData: PollDTO?
    /// Brand name (for analytics)
    let brandName: String?
    /// Campaign name (for analytics)
    let campaignName: String?

    // MARK: - Computed Properties

    /// Display title (falls back to name if title is empty)
    var displayTitle: String {
        if let title = title, !title.isEmpty {
            return title
        }
        return ""
    }

    /// Parsed timestamp date
    var timestampDate: Date? {
        guard let timestamp = timestamp else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: timestamp) {
            return date
        }
        // Try without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: timestamp)
    }

    /// Timestamp as milliseconds string (for analytics)
    var timestampMilliseconds: String {
        guard let date = timestampDate else { return "0" }
        let milliseconds = Int64(date.timeIntervalSince1970 * 1000)
        return String(milliseconds)
    }

    /// Whether this asset is a video
    var isVideo: Bool {
        type == .video
    }

    /// Whether this asset is an image
    var isImage: Bool {
        type == .image
    }

    /// Whether this asset is a poll
    var isPoll: Bool {
        type == .poll
    }

    /// Parent URL from CTA button (for analytics)
    var parentUrl: String? {
        ctaButton?.url
    }
}

// MARK: - HasImageURL Conformance
extension TimelineAssetDTO: HasImageURL {
    var imageURL: URL? {
        guard let media = media else { return nil }
        // For images, use mobileUrl; for videos, use coverUrl (thumbnail)
        if isVideo {
            return media.coverUrl.flatMap { URL(string: $0) }
        }
        return media.primaryUrl.flatMap { URL(string: $0) }
    }
}
