//
//  DetailSizeConfiguration.swift
//  CarouselDemo
//

import SwiftUI

// MARK: - DetailSizeConfiguration
/// Size configuration for the detail (fullscreen) cards
public struct DetailSizeConfiguration: Equatable, Sendable {

    // MARK: - Card
    /// Corner radius of the card
    public let cardCornerRadius: CGFloat
    /// Edge padding around the card
    public let edgePadding: CGFloat
    /// Spacing between card and products
    public let cardSpacing: CGFloat

    // MARK: - Progress Bar
    /// Height of the progress bar
    public let progressBarHeight: CGFloat

    // MARK: - Timestamp
    /// Font for timestamp label
    public let timestampFont: CarouselFontDescriptor
    /// Horizontal padding inside timestamp label
    public let timestampPaddingHorizontal: CGFloat
    /// Vertical padding inside timestamp label
    public let timestampPaddingVertical: CGFloat
    /// Corner radius of timestamp background
    public let timestampCornerRadius: CGFloat
    /// Top margin of timestamp from card edge
    public let timestampTopMargin: CGFloat
    /// Horizontal margin of timestamp from card edge
    public let timestampHorizontalMargin: CGFloat

    // MARK: - Brand Logo
    /// Size of the brand logo (width and height)
    public let brandLogoSize: CGFloat
    /// Corner radius of brand logo
    public let brandLogoCornerRadius: CGFloat

    // MARK: - Title & Subtitle
    /// Font for title
    public let titleFont: CarouselFontDescriptor
    /// Font for subtitle
    public let subtitleFont: CarouselFontDescriptor
    /// Spacing between content elements
    public let contentSpacing: CGFloat

    // MARK: - CTA Button
    /// Font for CTA button text
    public let ctaButtonFont: CarouselFontDescriptor
    /// Horizontal padding of CTA button
    public let ctaButtonPaddingHorizontal: CGFloat
    /// Vertical padding of CTA button
    public let ctaButtonPaddingVertical: CGFloat

    // MARK: - Action Buttons
    /// Icon size for action buttons (like, share, mute)
    public let actionButtonIconSize: CGFloat
    /// Spacing between action buttons
    public let actionButtonSpacing: CGFloat

    // MARK: - Content Layout
    /// Horizontal padding for overlay content (info section leading, action buttons trailing)
    public let contentHorizontalPadding: CGFloat
    /// Bottom padding of bottom info section
    public let bottomInfoPaddingBottom: CGFloat

    // MARK: - Poll
    /// Configuration for poll elements in detail view
    public let poll: PollSizeConfiguration

    public init(
        cardCornerRadius: CGFloat = 16,
        edgePadding: CGFloat = 16,
        cardSpacing: CGFloat = 8,
        progressBarHeight: CGFloat = 8,
        timestampFont: CarouselFontDescriptor = .system(size: 14, weight: .semibold),
        timestampPaddingHorizontal: CGFloat = 10,
        timestampPaddingVertical: CGFloat = 6,
        timestampCornerRadius: CGFloat = 8,
        timestampTopMargin: CGFloat = 16,
        timestampHorizontalMargin: CGFloat = 16,
        brandLogoSize: CGFloat = 60,
        brandLogoCornerRadius: CGFloat = 8,
        titleFont: CarouselFontDescriptor = .system(size: 22, weight: .bold),
        subtitleFont: CarouselFontDescriptor = .system(size: 18, weight: .semibold),
        contentSpacing: CGFloat = 8,
        ctaButtonFont: CarouselFontDescriptor = .system(size: 18, weight: .semibold),
        ctaButtonPaddingHorizontal: CGFloat = 20,
        ctaButtonPaddingVertical: CGFloat = 10,
        actionButtonIconSize: CGFloat = 24,
        actionButtonSpacing: CGFloat = 36,
        contentHorizontalPadding: CGFloat = 16,
        bottomInfoPaddingBottom: CGFloat = 24,
        poll: PollSizeConfiguration = .default
    ) {
        self.cardCornerRadius = cardCornerRadius
        self.edgePadding = edgePadding
        self.cardSpacing = cardSpacing
        self.progressBarHeight = progressBarHeight
        self.timestampFont = timestampFont
        self.timestampPaddingHorizontal = timestampPaddingHorizontal
        self.timestampPaddingVertical = timestampPaddingVertical
        self.timestampCornerRadius = timestampCornerRadius
        self.timestampTopMargin = timestampTopMargin
        self.timestampHorizontalMargin = timestampHorizontalMargin
        self.brandLogoSize = brandLogoSize
        self.brandLogoCornerRadius = brandLogoCornerRadius
        self.titleFont = titleFont
        self.subtitleFont = subtitleFont
        self.contentSpacing = contentSpacing
        self.ctaButtonFont = ctaButtonFont
        self.ctaButtonPaddingHorizontal = ctaButtonPaddingHorizontal
        self.ctaButtonPaddingVertical = ctaButtonPaddingVertical
        self.actionButtonIconSize = actionButtonIconSize
        self.actionButtonSpacing = actionButtonSpacing
        self.contentHorizontalPadding = contentHorizontalPadding
        self.bottomInfoPaddingBottom = bottomInfoPaddingBottom
        self.poll = poll
    }

    /// Default detail configuration
    public static let `default` = DetailSizeConfiguration()
}
