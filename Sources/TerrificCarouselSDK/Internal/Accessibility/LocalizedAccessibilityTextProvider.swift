//
//  LocalizedAccessibilityTextProvider.swift
//  TerrificCarouselSDK
//

import Foundation

// MARK: - LocalizedAccessibilityTextProvider
/// Localized implementation of AccessibilityTextProvider.
/// Reads strings from Localizable.strings files based on device locale.
/// Automatically selects the appropriate language (falls back to English).
struct LocalizedAccessibilityTextProvider: AccessibilityTextProvider {

    // MARK: - Properties

    private let bundle: Bundle

    // MARK: - Init

    /// Creates a localized accessibility text provider.
    /// - Parameter bundle: The bundle containing localization resources. Defaults to the SDK bundle.
    ///
    /// Explicitly resolves the correct `.lproj` sub-bundle for the user's preferred language.
    /// This is necessary because `NSLocalizedString` with `Bundle.module` relies on the host app's
    /// `CFBundleLocalizations` to determine the language. If the host app doesn't declare a language
    /// that the SDK supports, `NSLocalizedString` falls back to the development language (English)
    /// even when the SDK has the correct `.lproj` resources.
    ///
    /// We bypass `Bundle.preferredLocalizations(from:)` because it is also filtered by the host app.
    /// Instead, we match `Locale.preferredLanguages` (the raw system preference) against the
    /// bundle's available `.lproj` directories ourselves.
    init(bundle: Bundle = .module) {
        let bundleLocalizations = bundle.localizations

        for language in Locale.preferredLanguages {
            let code = Locale(identifier: language).language.languageCode?.identifier ?? language
            if bundleLocalizations.contains(code),
               let path = bundle.path(forResource: code, ofType: "lproj"),
               let localizedBundle = Bundle(path: path) {
                self.bundle = localizedBundle
                return
            }
        }

        self.bundle = bundle
    }

    // MARK: - Private Helpers

    private func localized(_ key: String) -> String {
        NSLocalizedString(key, bundle: bundle, comment: "")
    }

    private func localized(_ key: String, _ args: CVarArg...) -> String {
        let format = localized(key)
        return String(format: format, arguments: args)
    }

    // MARK: - Carousel Navigation

    var carouselLabel: String {
        localized("accessibility.carousel.label")
    }

    var carouselHint: String {
        localized("accessibility.carousel.hint")
    }

    func itemPositionLabel(current: Int, total: Int) -> String {
        localized("accessibility.carousel.item_position", current, total)
    }

    // MARK: - Feed View

    func feedAssetCardLabel(title: String, subtitle: String?, mediaType: AssetMediaTypeData, pollQuestion: String?) -> String {
        let typeLabel: String
        switch mediaType {
        case .image: typeLabel = localized("accessibility.feed.card.type.image")
        case .video: typeLabel = localized("accessibility.feed.card.type.video")
        case .poll: typeLabel = localized("accessibility.feed.card.type.poll")
        case .ad: typeLabel = localized("accessibility.feed.card.type.ad")
        }

        if mediaType == .poll, let pollQuestion {
            if let subtitle {
                return localized("accessibility.feed.card.label_poll_with_subtitle", title, subtitle, typeLabel, pollQuestion)
            }
            return localized("accessibility.feed.card.label_poll", title, typeLabel, pollQuestion)
        }

        if let subtitle {
            return localized("accessibility.feed.card.label_with_subtitle", title, subtitle, typeLabel)
        }
        return localized("accessibility.feed.card.label", title, typeLabel)
    }

    var feedAssetCardHint: String {
        localized("accessibility.feed.card.hint")
    }

    // MARK: - Detail View

    var closeButtonLabel: String {
        localized("accessibility.detail.close.label")
    }

    var closeButtonHint: String {
        localized("accessibility.detail.close.hint")
    }

    func detailAssetLabel(title: String, subtitle: String?) -> String {
        if let subtitle {
            return localized("accessibility.detail.asset.label_with_subtitle", title, subtitle)
        }
        return title
    }

    var readMoreButtonLabel: String {
        localized("accessibility.detail.read_more")
    }

    var readLessButtonLabel: String {
        localized("accessibility.detail.read_less")
    }

    func currentPageIndexLabel(current: Int, total: Int) -> String {
        localized("accessibility.detail.page_index", current, total)
    }

    // MARK: - Action Buttons

    var likeButtonLabel: String {
        localized("accessibility.action.like")
    }

    var unlikeButtonLabel: String {
        localized("accessibility.action.unlike")
    }

    var shareButtonLabel: String {
        localized("accessibility.action.share")
    }

    var muteButtonLabel: String {
        localized("accessibility.action.mute")
    }

    var unmuteButtonLabel: String {
        localized("accessibility.action.unmute")
    }

    // MARK: - CTA Button

    func ctaButtonLabel(title: String) -> String {
        title
    }

    // MARK: - Polls

    func pollQuestionLabel(question: String) -> String {
        localized("accessibility.poll.question", question)
    }

    func pollOptionLabel(text: String) -> String {
        text
    }

    func pollOptionHint(isInteractive: Bool) -> String {
        isInteractive ? localized("accessibility.poll.option.hint") : ""
    }

    func pollOptionAnsweredLabel(text: String, percentage: Int, isSelected: Bool) -> String {
        if isSelected {
            return localized("accessibility.poll.option.answered_selected", text, percentage)
        }
        return localized("accessibility.poll.option.answered", text, percentage)
    }

    // MARK: - Products

    func productLabel(title: String, subtitle: String?, price: String?) -> String {
        switch (subtitle, price) {
        case let (subtitle?, price?):
            return localized("accessibility.product.label_full", title, subtitle, price)
        case let (subtitle?, nil):
            return localized("accessibility.product.label_with_subtitle", title, subtitle)
        case let (nil, price?):
            return localized("accessibility.product.label_with_price", title, price)
        case (nil, nil):
            return title
        }
    }

    func sponsorBadgeLabel(text: String) -> String {
        text
    }

    func productCtaButtonLabel(title: String) -> String {
        title
    }

    // MARK: - Media

    func imageLabel(description: String?) -> String {
        description ?? localized("accessibility.media.image")
    }

    func videoLabel(isMuted: Bool) -> String {
        if isMuted {
            return localized("accessibility.media.video.muted")
        }
        return localized("accessibility.media.video.with_audio")
    }

    // MARK: - Loading States

    var loadingLabel: String {
        localized("accessibility.loading")
    }

    // MARK: - Error View

    var errorTitle: String {
        localized("error.title")
    }

    var errorSubtitle: String {
        localized("error.subtitle")
    }

    var errorRetryButton: String {
        localized("error.retry_button")
    }

    var errorAccessibilityLabel: String {
        localized("accessibility.error.label")
    }

    var errorRetryHint: String {
        localized("accessibility.error.retry_hint")
    }

    // MARK: - Carousel Scroll Buttons

    var scrollPreviousButtonLabel: String {
        localized("accessibility.carousel.scroll_previous")
    }

    var scrollPreviousButtonHint: String {
        localized("accessibility.carousel.scroll_previous_hint")
    }

    var scrollNextButtonLabel: String {
        localized("accessibility.carousel.scroll_next")
    }

    var scrollNextButtonHint: String {
        localized("accessibility.carousel.scroll_next_hint")
    }

    // MARK: - Swipe Hint

    var swipeHintLabel: String {
        localized("accessibility.swipe_hint")
    }
}
