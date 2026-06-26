//
//  SponsorshipDTO.swift
//  TerrificCarouselSDK
//

import Foundation

// MARK: - SponsorshipDTO
/// Sponsorship configuration from the API.
/// Contains settings for both horizontal (feed) and vertical (detail) carousel sponsorship.
struct SponsorshipDTO: Codable, Equatable, Hashable {
    /// Whether HCarousel sponsorship is enabled
    let enabled: Bool?
    /// Text label displayed above the carousel name (e.g., "Brought to you by")
    let sponsorLabel: String?
    /// Logo URL displayed next to the sponsor label
    let topLogoUrl: String?
    /// Logo URL displayed at the bottom of the HCarousel
    let sideLogoUrl: String?
    /// Background color hex string for the carousel area
    let backgroundColor: String?
    /// Redirect URL when sponsor area is tapped
    let clickRedirect: String?
    /// Whether VCarousel sponsorship is enabled
    let verticalEnabled: Bool?
    /// Redirect URL for VCarousel sponsor tap
    let verticalClickRedirect: String?
    /// Ad placement type: "badge" or "banner" (for VCarousel)
    let adPlacementType: String?
    /// Poll sponsorship configuration
    let poll: SponsorshipPollDTO?
    /// Badge sponsorship configuration (for VCarousel)
    let badge: SponsorshipBadgeDTO?
    /// Banner sponsorship configuration (for VCarousel)
    let banner: SponsorshipBannerDTO?
}

// MARK: - SponsorshipPollDTO
/// Poll-specific sponsorship configuration.
struct SponsorshipPollDTO: Codable, Equatable, Hashable {
    /// Logo URL for the poll sponsor
    let logoUrl: String?
    /// Position of the ad: "top" or "bottom"
    let adPosition: String?
    /// Redirect URL when poll sponsor is tapped
    let clickRedirect: String?
}

// MARK: - SponsorshipBadgeDTO
/// Badge sponsorship configuration for VCarousel.
struct SponsorshipBadgeDTO: Codable, Equatable, Hashable {
    /// Redirect URL when badge is tapped
    let clickRedirect: String?
    /// Logo URL for the badge
    let logoUrl: String?
    /// Title text for the badge
    let title: String?
    /// Background color hex string
    let backgroundColor: String?
    /// Badge position: "top-left", "top-center", or "top-right"
    let position: String?
}

// MARK: - SponsorshipBannerDTO
/// Banner sponsorship configuration for VCarousel.
struct SponsorshipBannerDTO: Codable, Equatable, Hashable {
    /// Redirect URL when banner is tapped
    let clickRedirect: String?
    /// Whether banner is at the bottom
    let isBottom: Bool?
    /// Logo URL for the banner
    let logoUrl: String?
    /// Background color hex string
    let backgroundColor: String?
    /// Banner position: "top-bottom", "bottom", or "top"
    let position: String?
}
