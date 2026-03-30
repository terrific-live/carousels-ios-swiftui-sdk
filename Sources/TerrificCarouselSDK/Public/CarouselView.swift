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
///     sizeConfiguration: .default,
///     onAnalyticsEvent: { event in
///         print("Event: \(event)")
///     }
/// )
/// ```
public struct CarouselView: View {

    // MARK: - Private
    private let coordinator: TimelineCoordinator
    private let sizeConfiguration: CarouselSizeConfiguration

    // MARK: - Public Init
    public init(
        apiConfiguration: APIConfiguration,
        sizeConfiguration: CarouselSizeConfiguration = .default,
        onAnalyticsEvent: ((CarouselAnalyticsEvent) -> Void)? = nil
    ) {
        let factory = CarouselFactory(configuration: apiConfiguration)
        self.coordinator = factory.makeTimelineCoordinator(
            onAnalyticsEvent: onAnalyticsEvent
        )
        self.sizeConfiguration = sizeConfiguration
    }

    // MARK: - Body
    public var body: some View {
        TimelineCoordinatorView(
            coordinator: coordinator,
            sizeConfiguration: sizeConfiguration
        )
    }
}
