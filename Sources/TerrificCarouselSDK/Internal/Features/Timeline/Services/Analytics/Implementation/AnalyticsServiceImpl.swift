//
//  AnalyticsServiceImpl.swift
//  CarouselDemo
//

import Foundation
import HTTPClient

// MARK: - AnalyticsServiceImpl
/// Real implementation of AnalyticsService
struct AnalyticsServiceImpl: AnalyticsService {

    // MARK: - Dependencies
    let client: Client
    let configuration: AnalyticsConfiguration

    // MARK: - Init
    init(client: Client, configuration: AnalyticsConfiguration) {
        self.client = client
        self.configuration = configuration
    }

    // MARK: - Helpers

    /// Builds a session ID for asset-level events: `carouselId~assetId`
    func sessionId(carouselId: String, assetId: String) -> String {
        "\(carouselId)~\(assetId)"
    }

    func mapCustomProducts(from products: [ProductDTO]?) -> [AnalyticCustomProduct] {
        (products ?? []).map { product in
            AnalyticCustomProduct(
                name: product.name ?? "",
                price: product.formattedPrice ?? String(product.price ?? 0),
                currency: product.currency ?? "",
                description: product.description ?? "",
                externalURL: product.externalUrl ?? ""
            )
        }
    }

    func mapAnalyticProducts(from products: [ProductDTO]?) -> [AnalyticProduct] {
        (products ?? []).map { product in
            AnalyticProduct(
                id: product.id,
                sku: product.sku ?? "",
                categories: product.categories ?? [],
                tags: []
            )
        }
    }

    func assetTypeString(from type: AssetMediaTypeDTO) -> String {
        switch type {
        case .video: return "video"
        case .image: return "image"
        case .poll: return "poll"
        case .ad: return "ad"
        }
    }
}
