//
//  ProductViewSizeConfiguration.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 10.02.2026.
//

import Foundation

// MARK: - Size Configuration
struct ProductViewSizeConfiguration: Equatable {
    // MARK: - Container
    let cornerRadius: CGFloat
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    let interItemVerticalSpacing: CGFloat

    // MARK: - Image
    let imageSize: CGFloat
    let imageCornerRadius: CGFloat
    let imageTrailingPadding: CGFloat

    // MARK: - Text
    let titleFontSize: CGFloat
    let subtitleFontSize: CGFloat
    let priceFontSize: CGFloat

    // MARK: - Badge
    let badgeFontSize: CGFloat
    let badgeHorizontalPadding: CGFloat
    let badgeVerticalPadding: CGFloat
    let badgeCornerRadius: CGFloat

    // MARK: - CTA Button
    let ctaFontSize: CGFloat
    let ctaHorizontalPadding: CGFloat
    let ctaVerticalPadding: CGFloat

    // MARK: - Computed
    var totalHeight: CGFloat {
        imageSize + verticalPadding * 2
    }

    // MARK: - Presets

    /// Detail mode: larger image (80pt), full content
    static let detail = ProductViewSizeConfiguration(
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
    static let feed = ProductViewSizeConfiguration(
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
