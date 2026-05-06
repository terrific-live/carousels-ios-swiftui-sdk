//
//  AccessibilityTextProvider.swift
//  TerrificCarouselSDK
//

import Foundation

// MARK: - AccessibilityTextProvider
/// Protocol defining all accessibility text used in the SDK.
/// All strings are centralized here for easy management and future localization.
protocol AccessibilityTextProvider: Sendable {

    // MARK: - Carousel Navigation
    var carouselLabel: String { get }
    var carouselHint: String { get }
    func itemPositionLabel(current: Int, total: Int) -> String

    // MARK: - Feed View
    func feedAssetCardLabel(title: String, subtitle: String?, timestamp: String) -> String
    var feedAssetCardHint: String { get }

    // MARK: - Detail View
    var closeButtonLabel: String { get }
    var closeButtonHint: String { get }
    func detailAssetLabel(title: String, subtitle: String?) -> String
    var readMoreButtonLabel: String { get }
    var readLessButtonLabel: String { get }
    func currentPageIndexLabel(current: Int, total: Int) -> String

    // MARK: - Action Buttons
    var likeButtonLabel: String { get }
    var unlikeButtonLabel: String { get }
    var shareButtonLabel: String { get }
    var muteButtonLabel: String { get }
    var unmuteButtonLabel: String { get }

    // MARK: - CTA Button
    func ctaButtonLabel(title: String) -> String

    // MARK: - Polls
    func pollQuestionLabel(question: String) -> String
    func pollOptionLabel(text: String) -> String
    func pollOptionHint(isInteractive: Bool) -> String
    func pollOptionAnsweredLabel(text: String, percentage: Int, isSelected: Bool) -> String

    // MARK: - Products
    func productLabel(title: String, subtitle: String?, price: String?) -> String
    func sponsorBadgeLabel(text: String) -> String
    func productCtaButtonLabel(title: String) -> String

    // MARK: - Media
    func imageLabel(description: String?) -> String
    func videoLabel(isMuted: Bool) -> String

    // MARK: - Loading States
    var loadingLabel: String { get }

    // MARK: - Swipe Hint
    var swipeHintLabel: String { get }
}
