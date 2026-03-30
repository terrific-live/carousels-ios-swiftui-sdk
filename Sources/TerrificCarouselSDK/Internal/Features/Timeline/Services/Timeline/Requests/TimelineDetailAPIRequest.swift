//
//  TimelineDetailAPIRequest.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 26.02.2026.
//

import Foundation
import HTTPClient

// MARK: - TimelineDetailAPIRequest
/// Request for fetching timeline detail data (vertical display)
/// Endpoint: /api/v1/stores/{storeId}/display/{carouselId}
struct TimelineDetailAPIRequest: Request {
    typealias Response = TimelineResponseDTO

    let storeId: String
    let carouselId: String
    let numberOfItems: Int
    let offset: Int
    let shopPageUrl: String?
    let terrificUserId: String

    var path: EndpointPath? {
        "/api/v1/stores/\(storeId)/display/\(carouselId)"
    }

    var query: Query? {
        var params: Query = [
            "number-of-items": numberOfItems,
            "is-redirect": "false",
            "type": "timeline",
            "terrificUserId": terrificUserId
        ]

        if let encodedShopPageUrl = encodedShopPageUrl {
            params["shopPageUrl"] = encodedShopPageUrl
        }

        if offset > 0 {
            params["offset"] = offset
        }

        return params
    }

    // MARK: - Private

    /// Double URL-encoded shopPageUrl
    private var encodedShopPageUrl: String? {
        guard let shopPageUrl else { return nil }
        let firstPass = shopPageUrl.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? shopPageUrl
        return firstPass.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? firstPass
    }
}
