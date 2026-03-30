//
//  CarouselStyleConfiguration.swift
//  CarouselDemo
//
//  Public configuration for customizing carousel element sizes.
//

import Foundation

// MARK: - CarouselStyleConfiguration
/// Configuration for customizing sizes of carousel elements.
/// SDK users can provide custom configurations or use the provided defaults.
public struct CarouselStyleConfiguration: Equatable, Sendable {

    /// Configuration for the feed (horizontal carousel) view
    public let feed: FeedStyleConfiguration

    /// Configuration for the detail (fullscreen vertical) view
    public let detail: DetailStyleConfiguration

    public init(
        feed: FeedStyleConfiguration = .default,
        detail: DetailStyleConfiguration = .default
    ) {
        self.feed = feed
        self.detail = detail
    }

    /// Default configuration
    public static let `default` = CarouselStyleConfiguration()
}
