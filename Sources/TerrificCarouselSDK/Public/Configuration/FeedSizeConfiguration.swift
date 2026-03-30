//
//  FeedSizeConfiguration.swift
//  CarouselDemo
//

import SwiftUI

// MARK: - FeedSizeConfiguration
/// Size configuration for the feed (horizontal carousel) cards
public struct FeedSizeConfiguration: Equatable, Sendable {

    // MARK: - Carousel Layout
    /// Width of each carousel item
    public let carouselItemWidth: CGFloat
    /// Height of each carousel item
    public let carouselItemHeight: CGFloat
    /// Spacing between carousel items
    public let carouselItemSpacing: CGFloat
    /// Horizontal padding at carousel edges
    public let carouselHorizontalPadding: CGFloat

    // MARK: - Card
    /// Corner radius of the card
    public let cardCornerRadius: CGFloat
    /// Spacing between card and products
    public let cardSpacing: CGFloat

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

    // MARK: - Title & Subtitle
    /// Font for title
    public let titleFont: CarouselFontDescriptor
    /// Font for subtitle
    public let subtitleFont: CarouselFontDescriptor
    /// Spacing between title and subtitle
    public let titleSubtitleSpacing: CGFloat

    // MARK: - Bottom Info
    /// Horizontal padding of bottom info section
    public let bottomInfoPaddingHorizontal: CGFloat
    /// Bottom padding of bottom info section
    public let bottomInfoPaddingBottom: CGFloat

    // MARK: - Carousel Name Label
    /// Font for carousel name label
    public let carouselNameFont: CarouselFontDescriptor
    /// Color for carousel name label
    public let carouselNameColor: Color
    /// Bottom padding below carousel name label
    public let carouselNameBottomPadding: CGFloat
    /// Horizontal padding for carousel name label
    public let carouselNameHorizontalPadding: CGFloat

    // MARK: - Poll
    /// Configuration for poll elements in feed
    public let poll: PollSizeConfiguration

    public init(
        carouselItemWidth: CGFloat = 240,
        carouselItemHeight: CGFloat = 420,
        carouselItemSpacing: CGFloat = 18,
        carouselHorizontalPadding: CGFloat = 16,
        cardCornerRadius: CGFloat = 16,
        cardSpacing: CGFloat = 8,
        timestampFont: CarouselFontDescriptor = .system(size: 14, weight: .semibold),
        timestampPaddingHorizontal: CGFloat = 10,
        timestampPaddingVertical: CGFloat = 6,
        timestampCornerRadius: CGFloat = 8,
        timestampTopMargin: CGFloat = 12,
        timestampHorizontalMargin: CGFloat = 12,
        titleFont: CarouselFontDescriptor = .system(size: 18, weight: .bold),
        subtitleFont: CarouselFontDescriptor = .system(size: 16, weight: .regular),
        titleSubtitleSpacing: CGFloat = 4,
        bottomInfoPaddingHorizontal: CGFloat = 12,
        bottomInfoPaddingBottom: CGFloat = 12,
        carouselNameFont: CarouselFontDescriptor = .system(size: 22, weight: .bold),
        carouselNameColor: Color = .white,
        carouselNameBottomPadding: CGFloat = 24,
        carouselNameHorizontalPadding: CGFloat = 16,
        poll: PollSizeConfiguration = .compact
    ) {
        self.carouselItemWidth = carouselItemWidth
        self.carouselItemHeight = carouselItemHeight
        self.carouselItemSpacing = carouselItemSpacing
        self.carouselHorizontalPadding = carouselHorizontalPadding
        self.cardCornerRadius = cardCornerRadius
        self.cardSpacing = cardSpacing
        self.timestampFont = timestampFont
        self.timestampPaddingHorizontal = timestampPaddingHorizontal
        self.timestampPaddingVertical = timestampPaddingVertical
        self.timestampCornerRadius = timestampCornerRadius
        self.timestampTopMargin = timestampTopMargin
        self.timestampHorizontalMargin = timestampHorizontalMargin
        self.titleFont = titleFont
        self.subtitleFont = subtitleFont
        self.titleSubtitleSpacing = titleSubtitleSpacing
        self.bottomInfoPaddingHorizontal = bottomInfoPaddingHorizontal
        self.bottomInfoPaddingBottom = bottomInfoPaddingBottom
        self.carouselNameFont = carouselNameFont
        self.carouselNameColor = carouselNameColor
        self.carouselNameBottomPadding = carouselNameBottomPadding
        self.carouselNameHorizontalPadding = carouselNameHorizontalPadding
        self.poll = poll
    }

    /// Default feed configuration
    public static let `default` = FeedSizeConfiguration()
}
