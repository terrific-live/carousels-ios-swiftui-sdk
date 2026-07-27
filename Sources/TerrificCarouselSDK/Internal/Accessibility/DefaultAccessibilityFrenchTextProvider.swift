//
//  DefaultAccessibilityFrenchTextProvider.swift
//  TerrificCarouselSDK
//

import Foundation

// MARK: - DefaultAccessibilityFrenchTextProvider
/// French implementation of AccessibilityTextProvider.
/// All strings are centralized here for easy management and future backend localization.
struct DefaultAccessibilityFrenchTextProvider: AccessibilityTextProvider {

    // MARK: - Carousel Navigation

    var carouselLabel: String { "Carrousel de contenu" }

    var carouselHint: String {
        "Liste déroulante horizontale. Balayez vers la gauche ou la droite pour parcourir plus d'éléments"
    }

    func itemPositionLabel(current: Int, total: Int) -> String {
        "Élément \(current) sur \(total)"
    }

    // MARK: - Feed View

    func feedAssetCardLabel(title: String, subtitle: String?, mediaType: AssetMediaTypeData, pollQuestion: String?) -> String {
        let typeLabel: String
        switch mediaType {
        case .image: typeLabel = "Image"
        case .video: typeLabel = "Vidéo"
        case .poll: typeLabel = "Sondage"
        case .ad: typeLabel = "Publicité"
        }

        var label = title
        if let subtitle { label += ". \(subtitle)" }
        label += ". \(typeLabel)"
        if mediaType == .poll, let pollQuestion {
            label += ". \(pollQuestion)"
        }
        return label
    }

    var feedAssetCardHint: String { "Appuyez pour ouvrir en plein écran" }

    // MARK: - Detail View

    var closeButtonLabel: String { "Fermer" }

    var closeButtonHint: String { "Fermer et revenir à la vue précédente" }

    func detailAssetLabel(title: String, subtitle: String?) -> String {
        if let subtitle {
            return "\(title). \(subtitle)"
        }
        return title
    }

    var readMoreButtonLabel: String { "Lire plus" }

    var readLessButtonLabel: String { "Lire moins" }

    func currentPageIndexLabel(current: Int, total: Int) -> String {
        "Page \(current) sur \(total)"
    }

    // MARK: - Action Buttons

    var likeButtonLabel: String { "Aimer" }

    var unlikeButtonLabel: String { "Ne plus aimer" }

    var shareButtonLabel: String { "Partager" }

    var muteButtonLabel: String { "Couper le son" }

    var unmuteButtonLabel: String { "Activer le son" }

    // MARK: - CTA Button

    func ctaButtonLabel(title: String) -> String { title }

    // MARK: - Polls

    func pollQuestionLabel(question: String) -> String {
        "Sondage : \(question)"
    }

    func pollOptionLabel(text: String) -> String { text }

    func pollOptionHint(isInteractive: Bool) -> String {
        isInteractive ? "Appuyez pour voter" : ""
    }

    func pollOptionAnsweredLabel(text: String, percentage: Int, isSelected: Bool) -> String {
        let selected = isSelected ? "Sélectionné. " : ""
        return "\(selected)\(text). \(percentage) pourcent"
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
        let audio = isMuted ? "son coupé" : "avec le son"
        return "Vidéo, \(audio). Avance automatiquement à la fin"
    }

    // MARK: - Loading States

    var loadingLabel: String { "Chargement du contenu" }

    // MARK: - Error View

    var errorTitle: String { "Impossible de charger\nce contenu" }

    var errorSubtitle: String { "Veuillez réessayer dans un moment." }

    var errorRetryButton: String { "Réessayer" }

    var errorAccessibilityLabel: String { "Erreur de chargement du contenu. Impossible de charger ce contenu. Veuillez réessayer dans un moment." }

    var errorRetryHint: String { "Appuyez pour recharger le contenu" }

    // MARK: - Carousel Scroll Buttons

    var scrollPreviousButtonLabel: String { "Élément précédent" }

    var scrollPreviousButtonHint: String { "Fait défiler le carrousel vers l'élément précédent" }

    var scrollNextButtonLabel: String { "Élément suivant" }

    var scrollNextButtonHint: String { "Fait défiler le carrousel vers l'élément suivant" }

    // MARK: - Swipe Hint

    var swipeHintLabel: String { "Balayez vers le haut ou le bas pour naviguer entre les éléments" }
}
