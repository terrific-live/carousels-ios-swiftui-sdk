//
//  CarouselConfigDTO.swift
//  CarouselDemo
//

import Foundation

// MARK: - CarouselConfigDTO
/// Configuration for the carousel from the API
struct CarouselConfigDTO: Codable, Equatable {
    /// Format string for timestamps (e.g., "{DD}/{MM}/{YYYY} - {hh}h{mm}")
    let timestampFormat: String?
    /// Whether to show the carousel name label
    let showName: Bool?
    /// Whether to auto-play the carousel
    let carouselAutoPlay: Bool?
    /// Auto-play interval in seconds
    let carouselAutoPlayInterval: Double?
    /// Carousel name/title to display
    let name: String?
    /// Whether to show timestamp labels on assets
    let showTimestamps: Bool?
    /// Whether to use asset brandName as product name in ProductView
    let mapBrandNameToProductName: Bool?
    /// Localized text for swipe up hint animation in vertical carousel
    let swipeUpText: String?
    /// Sponsorship configuration for carousel branding
    let sponsorship: SponsorshipDTO?
}

// MARK: - Default Instance
extension CarouselConfigDTO {
    /// Default configuration when none is provided by API
    static let `default` = CarouselConfigDTO(
        timestampFormat: nil,
        showName: false,
        carouselAutoPlay: false,
        carouselAutoPlayInterval: 4.0,
        name: nil,
        showTimestamps: true,
        mapBrandNameToProductName: false,
        swipeUpText: nil,
        sponsorship: nil
    )
}
