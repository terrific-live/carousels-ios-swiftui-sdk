//
//  ShareSheet13+.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 24.03.2026.
//

import UIKit

// MARK: - Share Helper (iOS 13+)
@MainActor
enum ShareHelper {

    /// Presents a share sheet with the given items (imperative approach)
    static func share(items: [Any]) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }

        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )

        // Find the topmost presented controller
        var topController = rootViewController
        while let presented = topController.presentedViewController {
            topController = presented
        }

        // Configure for iPad
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = topController.view
            popover.sourceRect = CGRect(
                x: topController.view.bounds.midX,
                y: topController.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }

        topController.present(activityVC, animated: true)
    }

    /// Creates share items from asset data with fallback logic
    /// Priority: CTA URL > First Product URL > Title + Description text
    static func createShareItems(from viewData: TimelineAssetData) -> [Any] {
        // Priority 1: CTA button URL
        if let ctaURL = viewData.ctaButton?.url {
            return [ctaURL]
        }

        // Priority 2: First product's external URL
        if let productURL = viewData.products.first?.ctaButton?.url {
            return [productURL]
        }

        // Priority 3: Title + description as text
        var textContent = viewData.title
        if let subtitle = viewData.subtitle, !subtitle.isEmpty {
            textContent += "\n\n\(subtitle)"
        }
        return [textContent]
    }
}
