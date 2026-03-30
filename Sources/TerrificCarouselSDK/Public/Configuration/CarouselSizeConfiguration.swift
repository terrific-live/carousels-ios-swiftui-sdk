//
//  CarouselSizeConfiguration.swift
//  CarouselDemo
//
//  Public configuration for customizing carousel element sizes.
//

import Foundation

// MARK: - CarouselSizeConfiguration
/// Configuration for customizing sizes of carousel elements.
/// SDK users can provide custom configurations or use the provided defaults.
public struct CarouselSizeConfiguration: Equatable, Sendable {

    /// Configuration for the feed (horizontal carousel) view
    public let feed: FeedSizeConfiguration

    /// Configuration for the detail (fullscreen vertical) view
    public let detail: DetailSizeConfiguration

    public init(
        feed: FeedSizeConfiguration = .default,
        detail: DetailSizeConfiguration = .default
    ) {
        self.feed = feed
        self.detail = detail
    }

    /// Default configuration
    public static let `default` = CarouselSizeConfiguration()
}
