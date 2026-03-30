//
//  TimelineAssetViewData.swift
//  CarouselDemo
//

import Foundation
import SwiftUI

/// Media type for the asset (includes poll and ad)
enum AssetMediaType: Equatable {
    case image
    case video
    case poll
    case ad
}

/// Data model for asset card view content
/// This is a View Model that contains formatted/prepared data for UI display
struct TimelineAssetData: Identifiable {

    // MARK: - Asset Identity & Media

    /// Unique identifier for the asset (assetId from API)
    let id: String

    /// Media type (image, video, or poll)
    let mediaType: AssetMediaType

    /// Image URL for the asset (poster/thumbnail for video, main image for image type)
    let imageURL: URL?

    /// Video URL for video assets (nil for image assets)
    let videoURL: URL?

    /// Video preview URL for feed (3-second preview)
    let videoPreviewURL: URL?

    /// Thumbnail/cover URL (shown while video loads)
    let thumbnailURL: URL?

    /// Poll view model for poll assets (nil for non-poll assets)
    /// Shared between Feed and Detail views
    let pollViewModel: PollViewModel?

    // MARK: - Overlay Content

    /// Timestamp displayed at the top (e.g., "17:05 | 05.02.26")
    let timestamp: Date

    /// Pre-formatted timestamp string using carouselConfig format
    let formattedTimestamp: String

    /// Whether to show the timestamp label
    let showTimestamp: Bool

    /// Title displayed at the bottom
    let title: String

    /// Subtitle/description text
    let subtitle: String?

    /// Brand logo URL (shown in detail view overlay)
    let brandLogoURL: String?

    // MARK: - CTA Button

    /// Call-to-action button data (nil if not visible)
    let ctaButton: CTAButtonData?

    // MARK: - Background Colors

    /// Primary background color
    let primaryBackgroundColor: Color

    /// Secondary background color (for gradients)
    let secondaryBackgroundColor: Color

    /// Whether the backend provided a custom background (affects layout)
    let hasCustomBackground: Bool

    // MARK: - Products

    /// Products associated with this asset
    let products: [ProductData]

    // MARK: - Init

    init(
        id: String,
        mediaType: AssetMediaType,
        imageURL: URL?,
        videoURL: URL?,
        videoPreviewURL: URL? = nil,
        thumbnailURL: URL? = nil,
        pollViewModel: PollViewModel? = nil,
        timestamp: Date,
        formattedTimestamp: String? = nil,
        showTimestamp: Bool = true,
        title: String,
        subtitle: String? = nil,
        brandLogoURL: String? = nil,
        ctaButton: CTAButtonData? = nil,
        primaryBackgroundColor: Color = .black,
        secondaryBackgroundColor: Color = .black,
        hasCustomBackground: Bool = false,
        products: [ProductData] = []
    ) {
        self.id = id
        self.mediaType = mediaType
        self.imageURL = imageURL
        self.videoURL = videoURL
        self.videoPreviewURL = videoPreviewURL
        self.thumbnailURL = thumbnailURL
        self.pollViewModel = pollViewModel
        self.timestamp = timestamp
        self.formattedTimestamp = formattedTimestamp ?? Self.defaultFormattedTimestamp(timestamp)
        self.showTimestamp = showTimestamp
        self.title = title
        self.subtitle = subtitle
        self.brandLogoURL = brandLogoURL
        self.ctaButton = ctaButton
        self.primaryBackgroundColor = primaryBackgroundColor
        self.secondaryBackgroundColor = secondaryBackgroundColor
        self.hasCustomBackground = hasCustomBackground
        self.products = products
    }

    /// Default timestamp formatting
    private static func defaultFormattedTimestamp(_ date: Date) -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        timeFormatter.dateStyle = .none

        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .short

        let time = timeFormatter.string(from: date)
        let dateStr = dateFormatter.string(from: date)

        return "\(dateStr) | \(time)"
    }

    // MARK: - Computed Properties

    /// Returns the video URL only if the asset is a video type
    var videoURLForPlayback: URL? {
        mediaType == .video ? videoURL : nil
    }

    /// Returns the video preview URL for feed (3-sec preview)
    var videoPreviewURLForFeed: URL? {
        mediaType == .video ? videoPreviewURL : nil
    }
}

// MARK: - Convenience Initializer from TimelineAsset
extension TimelineAssetData {

    /// Creates view data from asset with externally managed PollViewModel.
    /// Use this initializer when PollViewModel needs to persist across view recreations.
    /// - Parameters:
    ///   - asset: The timeline asset from service layer
    ///   - pollViewModel: Externally managed PollViewModel (from PollViewModelStore)
    ///   - carouselConfig: Configuration for timestamp formatting and visibility
    init(from asset: TimelineAssetDTO, pollViewModel: PollViewModel?, carouselConfig: CarouselConfigDTO = .default) {
        self.id = asset.id
        self.mediaType = AssetMediaType(from: asset.type)

        // Image URL - use cover for video, mobile URL for image
        if asset.isVideo {
            self.imageURL = asset.media?.coverUrl.flatMap { URL(string: $0) }
        } else {
            self.imageURL = asset.media?.primaryUrl.flatMap { URL(string: $0) }
        }

        // Video URL - only set for video type
        if asset.isVideo {
            self.videoURL = asset.media?.primaryUrl.flatMap { URL(string: $0) }
            self.videoPreviewURL = asset.media?.videoPreviewUrl.flatMap { URL(string: $0) }
            self.thumbnailURL = asset.media?.coverUrl.flatMap { URL(string: $0) }
        } else {
            self.videoURL = nil
            self.videoPreviewURL = nil
            self.thumbnailURL = nil
        }

        // Use externally provided PollViewModel
        self.pollViewModel = pollViewModel

        // Timestamp - parse from ISO8601 string and format using carouselConfig
        let timestampDate = asset.timestampDate ?? Date()
        self.timestamp = timestampDate
        self.formattedTimestamp = carouselConfig.formatTimestamp(timestampDate)
        self.showTimestamp = carouselConfig.showTimestamps ?? true

        // Title - use displayTitle which handles fallback to name
        self.title = asset.displayTitle

        // Subtitle - use description if not empty
        if let description = asset.description, !description.isEmpty {
            self.subtitle = description
        } else {
            self.subtitle = nil
        }

        // Brand logo
        self.brandLogoURL = asset.brandLogo?.imageUrl

        // CTA Button
        if let ctaButton = asset.ctaButton {
            self.ctaButton = CTAButtonData(
                text: ctaButton.text ?? "",
                url: ctaButton.url.flatMap { URL(string: $0) },
                backgroundColor: Color(hex: ctaButton.color ?? "#000000"),
                textColor: Color(hex: ctaButton.textColor ?? "#000000")
            )
        } else {
            self.ctaButton = nil
        }

        // Background colors - with defaults
        if let background = asset.background, let bgColor = background.color {
            self.primaryBackgroundColor = Color(hex: bgColor.primary ?? "#000000")
            self.secondaryBackgroundColor = Color(hex: bgColor.secondary ?? "#000000")
            self.hasCustomBackground = true
        } else {
            self.primaryBackgroundColor = .black
            self.secondaryBackgroundColor = .black
            self.hasCustomBackground = false
        }

        // Products - map from DTO
        self.products = (asset.products ?? []).map { ProductData(from: $0) }
    }
}

// MARK: - AssetMediaViewType Conversion
extension AssetMediaType {
    init(from mediaType: AssetMediaTypeDTO) {
        switch mediaType {
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
