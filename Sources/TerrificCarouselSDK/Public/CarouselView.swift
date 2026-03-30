//
//  CarouselView.swift
//  TerrificCarouselSDK
//
//  Public entry point for the TerrificCarouselSDK.
//

import SwiftUI

// MARK: - CarouselView
/// Public entry point for the TerrificCarouselSDK.
/// Use this view to display a carousel with the specified configuration.
///
/// Example usage:
/// ```swift
/// CarouselView(
///     apiConfiguration: APIConfiguration(
///         baseURL: "https://api.example.com",
///         storeId: "store123",
///         carouselId: "carousel456",
///         shopPageUrl: nil
///     ),
///     styleConfiguration: .default,
///     onAnalyticsEvent: { event in
///         print("Event: \(event)")
///     }
/// )
/// ```
public struct CarouselView: View {

    // MARK: - Private
    private let coordinator: TimelineCoordinator
    private let styleConfiguration: CarouselStyleConfiguration

    // MARK: - Public Init
    public init(
        apiConfiguration: APIConfiguration,
        styleConfiguration: CarouselStyleConfiguration = .default,
        onAnalyticsEvent: ((CarouselAnalyticsEvent) -> Void)? = nil
    ) {
        let factory = CarouselFactory(configuration: apiConfiguration)
        self.coordinator = factory.makeTimelineCoordinator(
            onAnalyticsEvent: onAnalyticsEvent
        )
        self.styleConfiguration = styleConfiguration
    }

    // MARK: - Body
    public var body: some View {
        TimelineCoordinatorView(
            coordinator: coordinator,
            sizeConfiguration: styleConfiguration
        )
    }
}
