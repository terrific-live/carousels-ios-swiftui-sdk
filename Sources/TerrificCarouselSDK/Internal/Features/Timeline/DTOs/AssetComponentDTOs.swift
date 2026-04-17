//
//  AssetComponentDTOs.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 14.01.2026.
//

import Foundation

// MARK: - AssetMediaDTO
struct AssetMediaDTO: Codable, Equatable, Hashable {
    /// Thumbnail/cover image URL (shown while video loads)
    let coverUrl: String?
    /// Desktop video/image URL
    let desktopUrl: String?
    /// Mobile video/image URL (primary for mobile app)
    let mobileUrl: String?
    /// Source/original URL
    let srcUrl: String?
    /// 3-second video preview URL (for feed autoplay)
    let videoPreviewUrl: String?

    // MARK: - Computed Properties

    /// Primary URL for mobile playback (mobileUrl fallback to srcUrl)
    var primaryUrl: String? {
        mobileUrl ?? srcUrl
    }

    /// Thumbnail URL for loading state
    var thumbnailUrl: String? {
        coverUrl
    }

    /// Preview URL for feed (3-sec video or cover)
    var previewUrl: String? {
        videoPreviewUrl ?? coverUrl
    }
}

// MARK: - AssetMediaType
enum AssetMediaTypeDTO: String, Codable, Hashable {
    case image
    case video
    case poll
    case ad
}

// MARK: - AssetCTAButtonDTO
struct AssetCTAButtonDTO: Codable, Equatable, Hashable {
    let color: String?
    let position: String?
    let text: String?
    let textColor: String?
    let url: String?
}

// MARK: - AssetBackgroundDTO
struct AssetBackgroundDTO: Codable, Equatable, Hashable {
    let type: BackgroundTypeDTO?
    let color: BackgroundColorDTO?
    let imageUrl: String?
    let textColor: String?
}

// MARK: - BackgroundTypeDTO
enum BackgroundTypeDTO: String, Codable, Hashable {
    case color
    case image
    case none
}

// MARK: - BackgroundColorDTO
struct BackgroundColorDTO: Codable, Equatable, Hashable {
    let primary: String?
    let secondary: String?
}

// MARK: - BrandLogoDTO
struct BrandLogoDTO: Codable, Equatable, Hashable {
    let imageUrl: String?
}
