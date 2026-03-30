//
//  AnalyticsEventAPIRequest.swift
//  CarouselDemo
//

import Foundation
import HTTPClient

// MARK: - Shared Analytics Types

/// Custom product info for analytics events
struct AnalyticCustomProduct: Encodable {
    let name: String
    let price: String
    let currency: String
    let description: String
    let externalURL: String
}

/// Product info for AssetViewStarted/AssetViewEnded events
struct AnalyticProduct: Encodable {
    let id: String
    let sku: String
    let categories: [String]
    let tags: [String]
}

// MARK: - TimelineOpened AuxData
struct TimelineOpenedAuxData: Encodable {
    let externalUserId: String?
    let userAgent: String
    let parentUrl: String
}

// MARK: - TimelineClosed AuxData
struct TimelineClosedAuxData: Encodable {
    let activeViewDurationMs: Int
    let externalUserId: String?
    let parentUrl: String
    let totalOpenDurationMs: Int
}

// MARK: - AssetViewStarted AuxData
struct AssetViewStartedAuxData: Encodable {
    let assetType: String
    let brandName: String?
    let campaignName: String?
    let customProducts: [AnalyticCustomProduct]
    let externalUserId: String?
    let fixedPosition: Int?
    let parentUrl: String
    let position: Int
    let products: [AnalyticProduct]
}

// MARK: - AssetViewEnded AuxData

/// drawerOpenDurationMs - the amount of time the product drawer (that allows to add to cart) was open during the asset playing.
/// netoAssetWatchTimeMs - the amount of time the use was actually seeing the content of the asset (without any time he was with drawer open or moved to other tabs or applications)
/// viewDurationMs - the total time the user was on the asset including the amount of time of drawer and tab switches and etc (end time minus start time)
struct AssetViewEndedAuxData: Encodable {
    let assetType: String
    let brandName: String?
    let campaignName: String?
    let customProducts: [AnalyticCustomProduct]
    let drawerOpenDurationMs: Int
    let externalUserId: String?
    let netoAssetWatchTimeMs: Int
    let parentUrl: String
    let position: Int
    let products: [AnalyticProduct]
    let viewDurationMs: Int
}

// MARK: - AssetLiked AuxData
struct AssetLikedAuxData: Encodable {
    let brandName: String?
    let campaignName: String?
    let externalUserId: String?
    let userAgent: String
    let parentUrl: String
    let position: Int
}

// MARK: - CarouselLoaded AuxData
struct CarouselLoadedAuxData: Encodable {
    let assetIds: [String]
    let assetTimestamps: [String]
    let externalUserId: String?
    let userAgent: String
    let parentUrl: String
    let position: Int?
    let totalAssets: Int
}

// MARK: - CarouselViewed AuxData
struct CarouselViewedAuxData: Encodable {
    let assetIds: [String]
    let assetTimestamps: [String]
    let externalUserId: String?
    let userAgent: String
    let parentUrl: String
    let position: Int?
    let totalAssets: Int
}

// MARK: - AssetViewed AuxData
struct AssetViewedAuxData: Encodable {
    let assetTimestamp: String
    let brandName: String?
    let campaignName: String?
    let externalUserId: String?
    let userAgent: String
    let parentUrl: String
    let isInitialView: Bool
    let position: Int
    let fixedPosition: Int
    let customProducts: [AnalyticCustomProduct]
}

// MARK: - CarouselClicked AuxData
struct CarouselClickedAuxData: Encodable {
    let assetId: String
    let assetIds: [String]
    let assetTimestamps: [String]
    let brandName: String?
    let campaignName: String?
    let customProducts: [String]
    let externalUserId: String?
    let parentUrl: String
    let position: Int
    let totalAssets: Int
}

// MARK: - CTAButtonClicked AuxData
struct CTAButtonClickedAuxData: Encodable {
    let brandName: String?
    let campaignName: String?
    let customProducts: [AnalyticCustomProduct]
    let externalUserId: String?
    let parentUrl: String
    let position: Int
    let targetUrl: String
    let terrificClickId: String?
    let url: String
    let userAgent: String
}

// MARK: - AssetShared AuxData
struct AssetSharedAuxData: Encodable {
    let brandName: String?
    let campaignName: String?
    let customProducts: [AnalyticCustomProduct]
    let externalUserId: String?
    let parentUrl: String
    let position: Int
    let userAgent: String
}

// MARK: - PollVoted AuxData
struct PollVotedAuxData: Encodable {
    let brandName: String?
    let campaignName: String?
    let externalUserId: String?
    let parentUrl: String
    let position: Int
    let questionId: String
    let userAgent: String
}

// MARK: - PollVoted Request Body (includes pollId and pollAnswer)
struct PollVotedRequestBody<AuxData: Encodable>: Encodable {
    let name: AnalyticsEventName
    let userId: String
    let sessionId: String
    let pollId: String
    let pollAnswer: String
    let auxData: AuxData
}

// MARK: - PollVoted API Request
struct PollVotedAPIRequest<AuxData: Encodable>: Request {
    typealias Response = EmptyResponse

    let storeId: String
    let requestBody: PollVotedRequestBody<AuxData>

    var method: HTTPMethod { .post }

    var headers: Headers? {
        [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "terrific-store-id": storeId
        ]
    }

    var path: EndpointPath? {
        "/userEvents"
    }

    var body: Encodable? {
        requestBody
    }
}

// MARK: - Generic Request Body
struct AnalyticsEventRequestBody<AuxData: Encodable>: Encodable {
    let name: AnalyticsEventName
    let userId: String
    let sessionId: String
    let auxData: AuxData
}

// MARK: - AnalyticsEventAPIRequest
/// Request for sending analytics events
/// Endpoint: POST /userEvents
struct AnalyticsEventAPIRequest<AuxData: Encodable>: Request {
    typealias Response = EmptyResponse

    let storeId: String
    let requestBody: AnalyticsEventRequestBody<AuxData>

    var method: HTTPMethod { .post }

    var headers: Headers? {
        [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "terrific-store-id": storeId
        ]
    }

    var path: EndpointPath? {
        "/userEvents"
    }

    var body: Encodable? {
        requestBody
    }
}
