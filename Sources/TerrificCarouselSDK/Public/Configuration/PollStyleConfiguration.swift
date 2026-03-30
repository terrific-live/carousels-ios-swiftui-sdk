//
//  PollSizeConfiguration.swift
//  CarouselDemo
//

import SwiftUI

// MARK: - PollSizeConfiguration
/// Size configuration for poll elements
public struct PollStyleConfiguration: Equatable, Sendable {

    /// Font for the question text
    public let questionFont: CarouselFontDescriptor
    /// Font for option text
    public let optionFont: CarouselFontDescriptor
    /// Font for option text when showing results (percentage)
    public let optionSelectedFont: CarouselFontDescriptor
    /// Height of each option button
    public let optionHeight: CGFloat
    /// Spacing between options
    public let optionSpacing: CGFloat
    /// Horizontal padding
    public let horizontalPadding: CGFloat
    /// Vertical padding
    public let verticalPadding: CGFloat

    public init(
        questionFont: CarouselFontDescriptor = .system(size: 26, weight: .medium),
        optionFont: CarouselFontDescriptor = .system(size: 18, weight: .medium),
        optionSelectedFont: CarouselFontDescriptor = .system(size: 18, weight: .semibold),
        optionHeight: CGFloat = 56,
        optionSpacing: CGFloat = 12,
        horizontalPadding: CGFloat = 32,
        verticalPadding: CGFloat = 24
    ) {
        self.questionFont = questionFont
        self.optionFont = optionFont
        self.optionSelectedFont = optionSelectedFont
        self.optionHeight = optionHeight
        self.optionSpacing = optionSpacing
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
    }

    /// Default poll configuration (detail size)
    public static let `default` = PollStyleConfiguration()

    /// Compact poll configuration (feed size)
    public static let compact = PollStyleConfiguration(
        questionFont: .system(size: 20, weight: .medium),
        optionFont: .system(size: 14, weight: .medium),
        optionSelectedFont: .system(size: 14, weight: .semibold),
        optionHeight: 44,
        optionSpacing: 8,
        horizontalPadding: 24,
        verticalPadding: 16
    )
}
