//
//  APIConfiguration.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 20.03.2026.
//

import Foundation

// MARK: - APIConfiguration
/// Configuration for the Carousel SDK API connection.
public struct APIConfiguration {
    public let baseURL: URL
    public let storeId: String
    public let carouselId: String
    public let shopPageUrl: String?

    // MARK: - Public Init with URL string
    public init(
        storeId: String,
        carouselId: String,
        baseURL: String? = nil,
        shopPageUrl: String? = nil
    ) {
        self.baseURL = baseURL.flatMap { URL(string: $0) } ?? URL(string: "https://terrific-live-polls.web.app")!
        self.storeId = storeId
        self.carouselId = carouselId
        self.shopPageUrl = shopPageUrl
    }
}
