//
//  DefaultAccessibilityTextProvider.swift
//  TerrificCarouselSDK
//

import Foundation

// MARK: - DefaultAccessibilityTextProvider
/// Default implementation of AccessibilityTextProvider with English strings.
/// All strings are centralized here for easy management and future backend localization.
struct DefaultAccessibilityTextProvider: AccessibilityTextProvider {

    // MARK: - Carousel Navigation

    var carouselLabel: String { "Content carousel" }

    var carouselHint: String {
        "Horizontal scrollable list. Swipe left or right to browse more items"
    }

// Example
//    "accessibility.item_position" : {
//        "localizations" : {
//            "en" : { "stringUnit" : { "value" : "Item %1$d of %2$d" } },
//            "de" : { "stringUnit" : { "value" : "Element %1$d von %2$d" } },
//            "ja" : { "stringUnit" : { "value" : "%2$d件中%1$d件目" } },
//            "fr" : { "stringUnit" : { "value" : "Élément %1$d sur %2$d" } }
//        }
//    }
//    %1$d - First integer argument (current),
//    %2$d - Second integer argument (total),
//    %1$@ - First string argument
    func itemPositionLabel(current: Int, total: Int) -> String {
        "Item \(current) of \(total)"
    }

    // MARK: - Feed View

    func feedAssetCardLabel(title: String, subtitle: String?, timestamp: String) -> String {
        if let subtitle {
            return "\(title). \(subtitle). Posted \(timestamp)"
        }
        return "\(title). Posted \(timestamp)"
    }

    var feedAssetCardHint: String { "Tap to open full screen" }

    // MARK: - Detail View

    var closeButtonLabel: String { "Close" }

    var closeButtonHint: String { "Dismiss and return to previous view" }

    func detailAssetLabel(title: String, subtitle: String?) -> String {
        if let subtitle {
            return "\(title). \(subtitle)"
        }
        return title
    }

    var readMoreButtonLabel: String { "Read more" }

    var readLessButtonLabel: String { "Read less" }

    func currentPageIndexLabel(current: Int, total: Int) -> String {
        "Page \(current) of \(total)"
    }

    // MARK: - Action Buttons

    var likeButtonLabel: String { "Like" }

    var unlikeButtonLabel: String { "Unlike" }

    var shareButtonLabel: String { "Share" }

    var muteButtonLabel: String { "Mute video" }

    var unmuteButtonLabel: String { "Unmute video" }

    // MARK: - CTA Button

    func ctaButtonLabel(title: String) -> String { title }

    // MARK: - Polls

    func pollQuestionLabel(question: String) -> String {
        "Poll: \(question)"
    }

    func pollOptionLabel(text: String) -> String { text }

    func pollOptionHint(isInteractive: Bool) -> String {
        isInteractive ? "Tap to vote" : ""
    }

    func pollOptionAnsweredLabel(text: String, percentage: Int, isSelected: Bool) -> String {
        let selected = isSelected ? "Selected. " : ""
        return "\(selected)\(text). \(percentage) percent"
    }

    // MARK: - Products

    func productLabel(title: String, subtitle: String?, price: String?) -> String {
        var label = title
        if let subtitle { label += ". \(subtitle)" }
        if let price { label += ". \(price)" }
        return label
    }

    func sponsorBadgeLabel(text: String) -> String { text }

    func productCtaButtonLabel(title: String) -> String { title }

    // MARK: - Media

    func imageLabel(description: String?) -> String {
        description ?? "Image"
    }

    func videoLabel(isMuted: Bool) -> String {
        let audio = isMuted ? "muted" : "with audio"
        return "Video, \(audio). Auto advances when finished"
    }

    // MARK: - Loading States

    var loadingLabel: String { "Loading content" }

    // MARK: - Swipe Hint

    var swipeHintLabel: String { "Swipe up or down to navigate between items" }
}
