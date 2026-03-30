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
        baseURL: String,
        storeId: String,
        carouselId: String,
        shopPageUrl: String?
    ) {
        self.baseURL = URL(string: baseURL)!
        self.storeId = storeId
        self.carouselId = carouselId
        self.shopPageUrl = shopPageUrl
    }
}
