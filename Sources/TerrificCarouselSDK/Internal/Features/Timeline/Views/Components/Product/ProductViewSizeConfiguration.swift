//
//  ProductViewSizeConfiguration.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 10.02.2026.
//

import Foundation

// MARK: - Size Configuration
public struct ProductViewSizeConfiguration: Equatable, Sendable {
    // MARK: - Container
    public let cornerRadius: CGFloat
    public let horizontalPadding: CGFloat
    public let verticalPadding: CGFloat
    public let interItemVerticalSpacing: CGFloat

    // MARK: - Image
    public let imageSize: CGFloat
    public let imageCornerRadius: CGFloat
    public let imageTrailingPadding: CGFloat

    // MARK: - Text
    public let titleFontSize: CGFloat
    public let subtitleFontSize: CGFloat
    public let priceFontSize: CGFloat

    // MARK: - Badge
    public let badgeFontSize: CGFloat
    public let badgeHorizontalPadding: CGFloat
    public let badgeVerticalPadding: CGFloat
    public let badgeCornerRadius: CGFloat

    // MARK: - CTA Button
    public let ctaFontSize: CGFloat
    public let ctaHorizontalPadding: CGFloat
    public let ctaVerticalPadding: CGFloat

    // MARK: - Computed
    public var totalHeight: CGFloat {
        imageSize + verticalPadding * 2
    }

    // MARK: - Init
    public init(
        cornerRadius: CGFloat,
        horizontalPadding: CGFloat,
        verticalPadding: CGFloat,
        interItemVerticalSpacing: CGFloat,
        imageSize: CGFloat,
        imageCornerRadius: CGFloat,
        imageTrailingPadding: CGFloat,
        titleFontSize: CGFloat,
        subtitleFontSize: CGFloat,
        priceFontSize: CGFloat,
        badgeFontSize: CGFloat,
        badgeHorizontalPadding: CGFloat,
        badgeVerticalPadding: CGFloat,
        badgeCornerRadius: CGFloat,
        ctaFontSize: CGFloat,
        ctaHorizontalPadding: CGFloat,
        ctaVerticalPadding: CGFloat
    ) {
        self.cornerRadius = cornerRadius
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.interItemVerticalSpacing = interItemVerticalSpacing
        self.imageSize = imageSize
        self.imageCornerRadius = imageCornerRadius
        self.imageTrailingPadding = imageTrailingPadding
        self.titleFontSize = titleFontSize
        self.subtitleFontSize = subtitleFontSize
        self.priceFontSize = priceFontSize
        self.badgeFontSize = badgeFontSize
        self.badgeHorizontalPadding = badgeHorizontalPadding
        self.badgeVerticalPadding = badgeVerticalPadding
        self.badgeCornerRadius = badgeCornerRadius
        self.ctaFontSize = ctaFontSize
        self.ctaHorizontalPadding = ctaHorizontalPadding
        self.ctaVerticalPadding = ctaVerticalPadding
    }

    // MARK: - Presets

    /// Detail mode: larger image (80pt), full content
    public static let detail = ProductViewSizeConfiguration(
        cornerRadius: 16,
        horizontalPadding: 12,
        verticalPadding: 12,
        interItemVerticalSpacing: 4,
        imageSize: 90,
        imageCornerRadius: 12,
        imageTrailingPadding: 8,
        titleFontSize: 18,
        subtitleFontSize: 15,
        priceFontSize: 16,
        badgeFontSize: 12,
        badgeHorizontalPadding: 10,
        badgeVerticalPadding: 4,
        badgeCornerRadius: 6,
        ctaFontSize: 16,
        ctaHorizontalPadding: 12,
        ctaVerticalPadding: 6
    )

    /// Feed mode: smaller image (40pt), compact content
    public static let feed = ProductViewSizeConfiguration(
        cornerRadius: 12,
        horizontalPadding: 10,
        verticalPadding: 10,
        interItemVerticalSpacing: 2,
        imageSize: 50,
        imageCornerRadius: 8,
        imageTrailingPadding: 6,
        titleFontSize: 14,
        subtitleFontSize: 12,
        priceFontSize: 12,
        badgeFontSize: 10,
        badgeHorizontalPadding: 8,
        badgeVerticalPadding: 2,
        badgeCornerRadius: 4,
        ctaFontSize: 12,
        ctaHorizontalPadding: 10,
        ctaVerticalPadding: 4
    )
}
