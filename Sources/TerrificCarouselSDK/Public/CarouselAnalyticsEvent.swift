//
//  CarouselAnalyticsEvent.swift
//  CarouselDemo
//
//  Analytics events emitted by the carousel.
//  SDK tracks these internally; users can optionally observe for custom analytics.
//

import Foundation

// MARK: - CarouselAnalyticsEvent
/// Analytics events emitted by the carousel.
///
/// The SDK tracks these events internally. Use `onAnalyticsEvent` callback
/// to observe events for your own analytics integration.
///
/// Example:
/// ```swift
/// CarouselView(
///     configuration: config,
///     onAnalyticsEvent: { event in
///         switch event {
///         case .assetViewed(let asset, let position, _):
///             myAnalytics.track("asset_viewed", ["id": asset.id])
///         default:
///             break
///         }
///     }
/// )
/// ```
public enum CarouselAnalyticsEvent: Sendable {

    // MARK: - Carousel Lifecycle Events

    /// Carousel data was loaded from the API
    /// - Parameter assets: All assets loaded in the carousel
    case carouselLoaded(assets: [CarouselAsset])

    /// Carousel became visible on screen
    /// - Parameter assets: All assets currently in the carousel
    case carouselViewed(assets: [CarouselAsset])

    /// User tapped on an asset to open detail view
    /// - Parameters:
    ///   - asset: The tapped asset
    ///   - position: Position of the asset in carousel
    case carouselClicked(asset: CarouselAsset, position: Int)

    // MARK: - Asset View Events

    /// An asset became visible in the carousel (feed or detail)
    /// - Parameters:
    ///   - asset: The viewed asset
    ///   - position: Position of the asset
    ///   - isInitialView: True if visible from start, false if scrolled into view
    case assetViewed(asset: CarouselAsset, position: Int, isInitialView: Bool)

    /// User started viewing an asset in detail view (for duration tracking)
    /// - Parameters:
    ///   - asset: The asset being viewed
    ///   - position: Position of the asset
    case assetViewStarted(asset: CarouselAsset, position: Int)

    /// User stopped viewing an asset in detail view
    /// - Parameters:
    ///   - asset: The asset that was viewed
    ///   - position: Position of the asset
    ///   - durationMs: How long the asset was viewed in milliseconds
    case assetViewEnded(asset: CarouselAsset, position: Int, durationMs: Int)

    // MARK: - Detail View Events

    /// Detail view (fullscreen timeline) was opened
    /// - Parameter parentUrl: The parent URL context
    case timelineOpened(parentUrl: String)

    /// Detail view was closed
    /// - Parameters:
    ///   - parentUrl: The parent URL context
    ///   - durationMs: Total time the detail view was open in milliseconds
    case timelineClosed(parentUrl: String, durationMs: Int)

    // MARK: - User Action Events

    /// User liked an asset
    /// - Parameter asset: The liked asset
    case assetLiked(asset: CarouselAsset)

    /// User shared an asset
    /// - Parameters:
    ///   - asset: The shared asset
    ///   - position: Position of the asset
    case assetShared(asset: CarouselAsset, position: Int)

    /// User clicked a CTA button
    /// - Parameters:
    ///   - asset: The asset containing the CTA
    ///   - position: Position of the asset
    ///   - targetUrl: The URL the CTA navigates to
    case ctaButtonClicked(asset: CarouselAsset, position: Int, targetUrl: String)

    /// User voted on a poll
    /// - Parameters:
    ///   - asset: The asset containing the poll
    ///   - position: Position of the asset
    ///   - pollId: The poll identifier
    ///   - answer: The selected answer text
    case pollVoted(asset: CarouselAsset, position: Int, pollId: String, answer: String)
}
