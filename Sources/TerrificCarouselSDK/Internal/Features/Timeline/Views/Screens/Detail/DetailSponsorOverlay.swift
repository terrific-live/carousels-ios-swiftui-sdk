//
//  DetailSponsorOverlay.swift
//  TerrificCarouselSDK
//

import SwiftUI
import ImageLoader

// MARK: - Sponsor Layout
/// Computes layout metrics and sponsor configuration for the detail asset card.
struct DetailSponsorLayout {

    // MARK: - Inputs
    let sponsorship: SponsorshipDTO?
    let mediaType: AssetMediaTypeData
    let sizeConfig: DetailStyleConfiguration
    let hasCustomBackground: Bool

    // MARK: - Overlay Visibility

    var shouldShowSponsorOverlay: Bool {
        guard sponsorship?.verticalEnabled == true,
              mediaType != .poll else { return false }
        switch sponsorship?.adPlacementType {
        case "badge": return sponsorship?.badge != nil
        case "banner": return sponsorship?.banner != nil
        default: return false
        }
    }

    var hasTopSponsorOverlay: Bool {
        guard shouldShowSponsorOverlay else { return false }
        if sponsorship?.adPlacementType == "badge" {
            return true
        }
        if sponsorship?.adPlacementType == "banner" {
            return showsTopBanner
        }
        return false
    }

    // MARK: - Layout Metrics

    var topSponsorInset: CGFloat {
        hasTopSponsorOverlay ? sizeConfig.sponsorBadgeHeight : 0
    }

    var bannerBottomInset: CGFloat {
        guard shouldShowSponsorOverlay,
              sponsorship?.adPlacementType == "banner",
              showsBottomBanner else { return 0 }
        return sizeConfig.sponsorBadgeHeight
    }

    var badgeAlignment: Alignment {
        guard shouldShowSponsorOverlay else { return .topLeading }
        switch sponsorPosition {
        case "top-center": return .top
        case "top-right": return .topTrailing
        default: return .topLeading
        }
    }

    // MARK: - Sponsor Data

    var sponsorLogoUrl: String? {
        if sponsorship?.adPlacementType == "badge" {
            return sponsorship?.badge?.logoUrl
        }
        return sponsorship?.banner?.logoUrl
    }

    var sponsorBackgroundColor: String? {
        if sponsorship?.adPlacementType == "badge" {
            return sponsorship?.badge?.backgroundColor
        }
        return sponsorship?.banner?.backgroundColor
    }

    var sponsorPosition: String {
        if sponsorship?.adPlacementType == "badge" {
            return sponsorship?.badge?.position ?? "top-left"
        }
        return sponsorship?.banner?.position ?? "top"
    }

    var sponsorAnalyticsPosition: SponsorshipPosition? {
        switch sponsorPosition {
        case "top", "top-left", "top-center", "top-right": return .top
        case "bottom": return .bottom
        case "top-bottom": return .both
        default: return nil
        }
    }

    var sponsorRedirectUrl: URL? {
        let urlString: String?
        if sponsorship?.adPlacementType == "badge" {
            urlString = sponsorship?.badge?.clickRedirect ?? sponsorship?.verticalClickRedirect
        } else {
            urlString = sponsorship?.banner?.clickRedirect ?? sponsorship?.verticalClickRedirect
        }
        guard let urlString else { return nil }
        return URL(string: urlString)
    }

    // MARK: - Banner Helpers

    var showsTopBanner: Bool {
        let pos = sponsorship?.banner?.position ?? "top"
        return pos == "top" || pos == "top-bottom"
    }

    var showsBottomBanner: Bool {
        let pos = sponsorship?.banner?.position ?? "top"
        return pos == "bottom" || pos == "top-bottom"
            || sponsorship?.banner?.isBottom == true
    }

    // MARK: - Badge Shape

    var badgeShape: UnevenRoundedRectangle {
        let outerRadius = hasCustomBackground ? sizeConfig.cardCornerRadius : 0
        let innerRadius: CGFloat = 8
        switch sponsorPosition {
        case "top-center":
            return UnevenRoundedRectangle(
                bottomLeadingRadius: innerRadius,
                bottomTrailingRadius: innerRadius
            )
        case "top-right":
            return UnevenRoundedRectangle(
                bottomLeadingRadius: innerRadius,
                topTrailingRadius: outerRadius
            )
        default: // "top-left"
            return UnevenRoundedRectangle(
                topLeadingRadius: outerRadius,
                bottomTrailingRadius: innerRadius
            )
        }
    }

    // MARK: - Poll Sponsor

    var shouldShowPollSponsor: Bool {
        sponsorship?.verticalEnabled == true
        && sponsorship?.poll != nil
        && sponsorship?.poll?.logoUrl != nil
    }

    var pollSponsorPosition: String {
        sponsorship?.poll?.adPosition ?? "top"
    }

    var pollSponsorRedirectUrl: URL? {
        guard let urlString = sponsorship?.poll?.clickRedirect else { return nil }
        return URL(string: urlString)
    }
}

// MARK: - Badge Overlay View
struct DetailSponsorBadgeOverlay: View {

    let layout: DetailSponsorLayout
    let onTap: (_ placement: AssetSponsorshipPlacement, _ position: SponsorshipPosition?, _ clickPosition: SponsorshipClickPosition, _ url: URL?) -> Void

    var body: some View {
        if layout.shouldShowSponsorOverlay && layout.sponsorship?.adPlacementType == "badge" {
            badgeView
                .onTapGesture {
                    onTap(
                        .badgeLogo,
                        layout.sponsorAnalyticsPosition,
                        layout.sponsorPosition.hasPrefix("top") ? .top : .bottom,
                        layout.sponsorRedirectUrl
                    )
                }
        }
    }

    private var badgeView: some View {
        HStack(spacing: 6) {
            if let logoUrl = layout.sponsorLogoUrl {
                CachedAsyncImage(urlString: logoUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .frame(height: layout.sizeConfig.sponsorBadgeHeight - layout.sizeConfig.sponsorBadgeVerticalPadding * 2)
            }
        }
        .padding(.vertical, layout.sizeConfig.sponsorBadgeVerticalPadding)
        .padding(.horizontal, 10)
        .background(layout.sponsorBackgroundColor.map { Color(hex: $0) } ?? .clear)
        .clipShape(layout.badgeShape)
    }
}

// MARK: - Banner Container Overlay View
struct DetailSponsorBannerOverlay: View {

    let layout: DetailSponsorLayout
    let onTap: (_ placement: AssetSponsorshipPlacement, _ position: SponsorshipPosition?, _ clickPosition: SponsorshipClickPosition, _ url: URL?) -> Void

    var body: some View {
        if layout.shouldShowSponsorOverlay && layout.sponsorship?.adPlacementType == "banner" {
            VStack {
                if layout.showsTopBanner {
                    bannerView
                        .onTapGesture {
                            onTap(.bannerLogo, layout.sponsorAnalyticsPosition, .top, layout.sponsorRedirectUrl)
                        }
                }
                Spacer()
                if layout.showsBottomBanner {
                    bannerView
                        .onTapGesture {
                            onTap(.bannerLogo, layout.sponsorAnalyticsPosition, .bottom, layout.sponsorRedirectUrl)
                        }
                }
            }
        }
    }

    private var bannerView: some View {
        HStack {
            if let logoUrl = layout.sponsorLogoUrl {
                CachedAsyncImage(urlString: logoUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .frame(height: layout.sizeConfig.sponsorBadgeHeight - layout.sizeConfig.sponsorBadgeVerticalPadding * 2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, layout.sizeConfig.sponsorBadgeVerticalPadding)
        .background(layout.sponsorBackgroundColor.map { Color(hex: $0) } ?? .clear)
    }
}

// MARK: - Poll Sponsor View
struct DetailPollSponsorView: View {

    let layout: DetailSponsorLayout

    var body: some View {
        if let logoUrl = layout.sponsorship?.poll?.logoUrl {
            HStack {
                CachedAsyncImage(urlString: logoUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .frame(height: layout.sizeConfig.sponsorBadgeHeight - layout.sizeConfig.sponsorBadgeVerticalPadding * 2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, layout.sizeConfig.sponsorBadgeVerticalPadding)
        }
    }
}
