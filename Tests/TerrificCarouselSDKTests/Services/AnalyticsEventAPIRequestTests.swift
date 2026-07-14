//
//  AnalyticsEventAPIRequestTests.swift
//  TerrificCarouselSDKTests
//

import XCTest
@testable import TerrificCarouselSDK

final class AnalyticsEventAPIRequestTests: XCTestCase {

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }()

    /// Helper to encode a value and decode it as a dictionary for key verification
    private func encodeToDictionary<T: Encodable>(_ value: T) throws -> [String: Any] {
        let data = try encoder.encode(value)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        return json
    }

    // MARK: - AnalyticsEventName

    func test_analyticsEventName_rawValues() {
        XCTAssertEqual(AnalyticsEventName.timelineOpened.rawValue, "TimelineOpened")
        XCTAssertEqual(AnalyticsEventName.timelineClosed.rawValue, "TimelineClosed")
        XCTAssertEqual(AnalyticsEventName.timelineAssetViewStarted.rawValue, "TimelineAssetViewStarted")
        XCTAssertEqual(AnalyticsEventName.timelineAssetViewEnded.rawValue, "TimelineAssetViewEnded")
        XCTAssertEqual(AnalyticsEventName.timelineAssetLiked.rawValue, "TimelineAssetLiked")
        XCTAssertEqual(AnalyticsEventName.timelineCarouselLoaded.rawValue, "TimelineCarouselLoaded")
        XCTAssertEqual(AnalyticsEventName.timelineCarouselViewed.rawValue, "TimelineCarouselViewed")
        XCTAssertEqual(AnalyticsEventName.timelineCarouselAssetViewed.rawValue, "TimelineCarouselAssetViewed")
        XCTAssertEqual(AnalyticsEventName.timelineCarouselClicked.rawValue, "TimelineCarouselClicked")
        XCTAssertEqual(AnalyticsEventName.timelineCTAButtonClicked.rawValue, "TimelineCTAButtonClicked")
        XCTAssertEqual(AnalyticsEventName.timelineAssetShared.rawValue, "TimelineAssetShared")
        XCTAssertEqual(AnalyticsEventName.timelinePollVoted.rawValue, "TimelinePollVoted")
        XCTAssertEqual(AnalyticsEventName.timelineProductClicked.rawValue, "TimelineProductClicked")
        XCTAssertEqual(AnalyticsEventName.timelineCarouselSponsorshipClicked.rawValue, "TimelineCarouselSponsorshipClicked")
        XCTAssertEqual(AnalyticsEventName.timelineAssetSponsorshipClicked.rawValue, "TimelineAssetSponsorshipClicked")
    }

    func test_analyticsEventName_encodesToRawValue() throws {
        let data = try encoder.encode(AnalyticsEventName.timelineOpened)
        let string = String(data: data, encoding: .utf8)
        XCTAssertEqual(string, "\"TimelineOpened\"")
    }

    // MARK: - Sponsorship Enums

    func test_carouselSponsorshipPlacement_rawValues() {
        XCTAssertEqual(CarouselSponsorshipPlacement.topLogo.rawValue, "TopLogo")
        XCTAssertEqual(CarouselSponsorshipPlacement.sideLogo.rawValue, "SideLogo")
    }

    func test_assetSponsorshipPlacement_rawValues() {
        XCTAssertEqual(AssetSponsorshipPlacement.badgeLogo.rawValue, "badgeLogo")
        XCTAssertEqual(AssetSponsorshipPlacement.bannerLogo.rawValue, "bannerLogo")
        XCTAssertEqual(AssetSponsorshipPlacement.pollLogo.rawValue, "pollLogo")
    }

    func test_sponsorshipPosition_rawValues() {
        XCTAssertEqual(SponsorshipPosition.top.rawValue, "top")
        XCTAssertEqual(SponsorshipPosition.bottom.rawValue, "bottom")
        XCTAssertEqual(SponsorshipPosition.both.rawValue, "both")
    }

    func test_sponsorshipClickPosition_rawValues() {
        XCTAssertEqual(SponsorshipClickPosition.top.rawValue, "Top")
        XCTAssertEqual(SponsorshipClickPosition.bottom.rawValue, "Bottom")
    }

    // MARK: - TimelineOpenedAuxData

    func test_timelineOpenedAuxData_encodesAllKeys() throws {
        let auxData = TimelineOpenedAuxData(
            externalUserId: "ext-123",
            userAgent: "iOS/17.0",
            parentUrl: "https://example.com"
        )

        let json = try encodeToDictionary(auxData)

        XCTAssertEqual(json["externalUserId"] as? String, "ext-123")
        XCTAssertEqual(json["userAgent"] as? String, "iOS/17.0")
        XCTAssertEqual(json["parentUrl"] as? String, "https://example.com")
        XCTAssertEqual(json.count, 3)
    }

    func test_timelineOpenedAuxData_nilExternalUserId_omitsKey() throws {
        let auxData = TimelineOpenedAuxData(
            externalUserId: nil,
            userAgent: "iOS/17.0",
            parentUrl: ""
        )

        let json = try encodeToDictionary(auxData)

        XCTAssertNil(json["externalUserId"])
        XCTAssertEqual(json.count, 2)
    }

    // MARK: - TimelineClosedAuxData

    func test_timelineClosedAuxData_encodesAllKeys() throws {
        let auxData = TimelineClosedAuxData(
            activeViewDurationMs: 5000,
            externalUserId: "ext-1",
            parentUrl: "",
            totalOpenDurationMs: 8000
        )

        let json = try encodeToDictionary(auxData)

        XCTAssertEqual(json["activeViewDurationMs"] as? Int, 5000)
        XCTAssertEqual(json["totalOpenDurationMs"] as? Int, 8000)
        XCTAssertEqual(json["parentUrl"] as? String, "")
        XCTAssertEqual(json["externalUserId"] as? String, "ext-1")
        XCTAssertEqual(json.count, 4)
    }

    // MARK: - AssetViewStartedAuxData

    func test_assetViewStartedAuxData_encodesAllKeys() throws {
        let product = AnalyticCustomProduct(
            name: "Shirt", price: "$29.99", currency: "USD",
            description: "A nice shirt", externalURL: "https://shop.com/shirt"
        )
        let analyticProduct = AnalyticProduct(
            id: "p1", sku: "SKU-001", categories: ["Clothing"], tags: ["summer"]
        )

        let auxData = AssetViewStartedAuxData(
            assetType: "video",
            brandName: "TestBrand",
            campaignName: "Summer2026",
            customProducts: [product],
            externalUserId: "ext-456",
            fixedPosition: 2,
            parentUrl: "",
            position: 2,
            products: [analyticProduct]
        )

        let json = try encodeToDictionary(auxData)

        XCTAssertEqual(json["assetType"] as? String, "video")
        XCTAssertEqual(json["brandName"] as? String, "TestBrand")
        XCTAssertEqual(json["campaignName"] as? String, "Summer2026")
        XCTAssertEqual(json["position"] as? Int, 2)
        XCTAssertEqual(json["fixedPosition"] as? Int, 2)
        XCTAssertEqual((json["customProducts"] as? [Any])?.count, 1)
        XCTAssertEqual((json["products"] as? [Any])?.count, 1)
        XCTAssertEqual(json.count, 9)
    }

    // MARK: - AssetViewEndedAuxData

    func test_assetViewEndedAuxData_encodesAllKeys() throws {
        let auxData = AssetViewEndedAuxData(
            assetType: "image",
            brandName: "Brand",
            campaignName: "Campaign",
            customProducts: [],
            drawerOpenDurationMs: 0,
            externalUserId: "ext-1",
            netoAssetWatchTimeMs: 3000,
            parentUrl: "",
            position: 1,
            products: [],
            viewDurationMs: 5000
        )

        let json = try encodeToDictionary(auxData)

        XCTAssertEqual(json["assetType"] as? String, "image")
        XCTAssertEqual(json["brandName"] as? String, "Brand")
        XCTAssertEqual(json["drawerOpenDurationMs"] as? Int, 0)
        XCTAssertEqual(json["netoAssetWatchTimeMs"] as? Int, 3000)
        XCTAssertEqual(json["viewDurationMs"] as? Int, 5000)
        XCTAssertEqual(json["position"] as? Int, 1)
        XCTAssertEqual(json.count, 11)
    }

    // MARK: - AssetLikedAuxData

    func test_assetLikedAuxData_encodesAllKeys() throws {
        let auxData = AssetLikedAuxData(
            brandName: "Brand",
            campaignName: "Campaign",
            externalUserId: "ext-1",
            userAgent: "iOS/17.0",
            parentUrl: "",
            position: 3
        )

        let json = try encodeToDictionary(auxData)

        XCTAssertEqual(json["brandName"] as? String, "Brand")
        XCTAssertEqual(json["position"] as? Int, 3)
        XCTAssertEqual(json["userAgent"] as? String, "iOS/17.0")
        XCTAssertEqual(json["externalUserId"] as? String, "ext-1")
        XCTAssertEqual(json.count, 6)
    }

    // MARK: - CarouselLoadedAuxData

    func test_carouselLoadedAuxData_encodesAllKeys() throws {
        let auxData = CarouselLoadedAuxData(
            assetIds: ["a1", "a2"],
            assetTimestamps: ["1000", "2000"],
            externalUserId: "ext-1",
            userAgent: "iOS/17.0",
            parentUrl: "",
            position: 3,
            totalAssets: 2
        )

        let json = try encodeToDictionary(auxData)

        XCTAssertEqual(json["assetIds"] as? [String], ["a1", "a2"])
        XCTAssertEqual(json["assetTimestamps"] as? [String], ["1000", "2000"])
        XCTAssertEqual(json["totalAssets"] as? Int, 2)
        XCTAssertEqual(json["position"] as? Int, 3)
        XCTAssertEqual(json["externalUserId"] as? String, "ext-1")
        XCTAssertEqual(json.count, 7)
    }

    func test_carouselLoadedAuxData_nilOptionals_omitsKeys() throws {
        let auxData = CarouselLoadedAuxData(
            assetIds: ["a1"],
            assetTimestamps: ["1000"],
            externalUserId: nil,
            userAgent: "iOS/17.0",
            parentUrl: "",
            position: nil,
            totalAssets: 1
        )

        let json = try encodeToDictionary(auxData)

        XCTAssertNil(json["position"])
        XCTAssertNil(json["externalUserId"])
        XCTAssertEqual(json.count, 5)
    }

    // MARK: - CarouselViewedAuxData

    func test_carouselViewedAuxData_encodesAllKeys() throws {
        let auxData = CarouselViewedAuxData(
            assetIds: ["a1"],
            assetTimestamps: ["1000"],
            externalUserId: "ext-1",
            userAgent: "iOS/17.0",
            parentUrl: "",
            position: 5,
            totalAssets: 1
        )

        let json = try encodeToDictionary(auxData)

        XCTAssertEqual(json["assetIds"] as? [String], ["a1"])
        XCTAssertEqual(json["position"] as? Int, 5)
        XCTAssertEqual(json["totalAssets"] as? Int, 1)
        XCTAssertEqual(json.count, 7)
    }

    // MARK: - AssetViewedAuxData

    func test_assetViewedAuxData_encodesAllKeys() throws {
        let auxData = AssetViewedAuxData(
            assetTimestamp: "1625000000",
            brandName: "Brand",
            campaignName: "Campaign",
            externalUserId: "ext-1",
            userAgent: "iOS/17.0",
            parentUrl: "",
            isInitialView: true,
            position: 0,
            fixedPosition: 0,
            customProducts: []
        )

        let json = try encodeToDictionary(auxData)

        XCTAssertEqual(json["assetTimestamp"] as? String, "1625000000")
        XCTAssertEqual(json["isInitialView"] as? Bool, true)
        XCTAssertEqual(json["fixedPosition"] as? Int, 0)
        XCTAssertEqual(json["campaignName"] as? String, "Campaign")
        XCTAssertEqual(json.count, 10)
    }

    // MARK: - CarouselClickedAuxData

    func test_carouselClickedAuxData_encodesAllKeys() throws {
        let auxData = CarouselClickedAuxData(
            assetId: "asset-1",
            assetIds: ["asset-1", "asset-2"],
            assetTimestamps: ["1000", "2000"],
            brandName: "Brand",
            campaignName: "Campaign",
            customProducts: [],
            externalUserId: "ext-1",
            parentUrl: "",
            position: 0,
            totalAssets: 2
        )

        let json = try encodeToDictionary(auxData)

        XCTAssertEqual(json["assetId"] as? String, "asset-1")
        XCTAssertEqual(json["assetIds"] as? [String], ["asset-1", "asset-2"])
        XCTAssertEqual(json["totalAssets"] as? Int, 2)
        XCTAssertEqual(json["externalUserId"] as? String, "ext-1")
        XCTAssertEqual(json.count, 10)
    }

    // MARK: - CTAButtonClickedAuxData

    func test_ctaButtonClickedAuxData_encodesAllKeys() throws {
        let auxData = CTAButtonClickedAuxData(
            brandName: "Brand",
            campaignName: "Campaign",
            customProducts: [],
            externalUserId: "ext-1",
            parentUrl: "",
            position: 1,
            targetUrl: "https://example.com/cta",
            terrificClickId: "click-abc",
            url: "https://example.com/cta",
            userAgent: "iOS/17.0"
        )

        let json = try encodeToDictionary(auxData)

        XCTAssertEqual(json["targetUrl"] as? String, "https://example.com/cta")
        XCTAssertEqual(json["terrificClickId"] as? String, "click-abc")
        XCTAssertEqual(json["url"] as? String, "https://example.com/cta")
        XCTAssertEqual(json.count, 10)
    }

    // MARK: - AssetSharedAuxData

    func test_assetSharedAuxData_encodesAllKeys() throws {
        let auxData = AssetSharedAuxData(
            brandName: "Brand",
            campaignName: "Campaign",
            customProducts: [],
            externalUserId: "ext-1",
            parentUrl: "",
            position: 2,
            userAgent: "iOS/17.0"
        )

        let json = try encodeToDictionary(auxData)

        XCTAssertEqual(json["position"] as? Int, 2)
        XCTAssertEqual(json["userAgent"] as? String, "iOS/17.0")
        XCTAssertEqual(json["brandName"] as? String, "Brand")
        XCTAssertEqual(json.count, 7)
    }

    // MARK: - PollVotedAuxData

    func test_pollVotedAuxData_encodesAllKeys() throws {
        let auxData = PollVotedAuxData(
            brandName: "Brand",
            campaignName: "Campaign",
            externalUserId: "ext-1",
            parentUrl: "",
            position: 0,
            questionId: "q-123",
            userAgent: "iOS/17.0"
        )

        let json = try encodeToDictionary(auxData)

        XCTAssertEqual(json["questionId"] as? String, "q-123")
        XCTAssertEqual(json["externalUserId"] as? String, "ext-1")
        XCTAssertEqual(json.count, 7)
    }

    // MARK: - ProductClickedAuxData

    func test_productClickedAuxData_encodesAllKeys() throws {
        let auxData = ProductClickedAuxData(
            id: "prod-1",
            name: "Test Product",
            description: "A product",
            externalURL: "https://shop.com/product",
            imageURL: "https://cdn.com/img.jpg",
            price: "$19.99",
            isCatalog: false,
            brandName: "Brand",
            campaignName: "Campaign",
            customProducts: [],
            externalUserId: "ext-1",
            parentUrl: "",
            position: 1,
            terrificClickId: "click-xyz",
            userAgent: "iOS/17.0"
        )

        let json = try encodeToDictionary(auxData)

        XCTAssertEqual(json["id"] as? String, "prod-1")
        XCTAssertEqual(json["name"] as? String, "Test Product")
        XCTAssertEqual(json["imageURL"] as? String, "https://cdn.com/img.jpg")
        XCTAssertEqual(json["isCatalog"] as? Bool, false)
        XCTAssertEqual(json["terrificClickId"] as? String, "click-xyz")
        XCTAssertEqual(json.count, 15)
    }

    // MARK: - CarouselSponsorshipClickedAuxData

    func test_carouselSponsorshipClickedAuxData_encodesAllKeys() throws {
        let auxData = CarouselSponsorshipClickedAuxData(
            parentUrl: "",
            externalUserId: "ext-1",
            sponsorshipPlacement: .topLogo,
            sponsorshipUrl: "https://sponsor.com"
        )

        let json = try encodeToDictionary(auxData)

        XCTAssertEqual(json["sponsorshipPlacement"] as? String, "TopLogo")
        XCTAssertEqual(json["sponsorshipUrl"] as? String, "https://sponsor.com")
        XCTAssertEqual(json["externalUserId"] as? String, "ext-1")
        XCTAssertEqual(json.count, 4)
    }

    // MARK: - AssetSponsorshipClickedAuxData

    func test_assetSponsorshipClickedAuxData_encodesAllKeys() throws {
        let auxData = AssetSponsorshipClickedAuxData(
            parentUrl: "",
            externalUserId: "ext-1",
            sponsorshipPlacement: .badgeLogo,
            sponsorshipPosition: .top,
            clickPosition: .top,
            sponsorshipUrl: "https://sponsor.com"
        )

        let json = try encodeToDictionary(auxData)

        XCTAssertEqual(json["sponsorshipPlacement"] as? String, "badgeLogo")
        XCTAssertEqual(json["sponsorshipPosition"] as? String, "top")
        XCTAssertEqual(json["clickPosition"] as? String, "Top")
        XCTAssertEqual(json["externalUserId"] as? String, "ext-1")
        XCTAssertEqual(json.count, 6)
    }

    func test_assetSponsorshipClickedAuxData_nilOptionals_omitsKeys() throws {
        let auxData = AssetSponsorshipClickedAuxData(
            parentUrl: "",
            externalUserId: nil,
            sponsorshipPlacement: .pollLogo,
            sponsorshipPosition: nil,
            clickPosition: nil,
            sponsorshipUrl: nil
        )

        let json = try encodeToDictionary(auxData)

        XCTAssertNil(json["sponsorshipPosition"])
        XCTAssertNil(json["clickPosition"])
        XCTAssertNil(json["sponsorshipUrl"])
        XCTAssertNil(json["externalUserId"])
        XCTAssertEqual(json.count, 2)
    }

    // MARK: - AnalyticCustomProduct

    func test_analyticCustomProduct_encodesAllKeys() throws {
        let product = AnalyticCustomProduct(
            name: "Widget",
            price: "$9.99",
            currency: "USD",
            description: "A widget",
            externalURL: "https://shop.com/widget"
        )

        let json = try encodeToDictionary(product)

        XCTAssertEqual(json["name"] as? String, "Widget")
        XCTAssertEqual(json["price"] as? String, "$9.99")
        XCTAssertEqual(json["currency"] as? String, "USD")
        XCTAssertEqual(json["description"] as? String, "A widget")
        XCTAssertEqual(json["externalURL"] as? String, "https://shop.com/widget")
        XCTAssertEqual(json.count, 5)
    }

    // MARK: - AnalyticProduct

    func test_analyticProduct_encodesAllKeys() throws {
        let product = AnalyticProduct(
            id: "p1",
            sku: "SKU-001",
            categories: ["Cat1", "Cat2"],
            tags: ["tag1"]
        )

        let json = try encodeToDictionary(product)

        XCTAssertEqual(json["id"] as? String, "p1")
        XCTAssertEqual(json["sku"] as? String, "SKU-001")
        XCTAssertEqual(json["categories"] as? [String], ["Cat1", "Cat2"])
        XCTAssertEqual(json["tags"] as? [String], ["tag1"])
        XCTAssertEqual(json.count, 4)
    }

    // MARK: - ProductClickedItem

    func test_productClickedItem_encodesAllKeys() throws {
        let item = ProductClickedItem(productId: "prod-1", variantId: "var-1")

        let json = try encodeToDictionary(item)

        XCTAssertEqual(json["productId"] as? String, "prod-1")
        XCTAssertEqual(json["variantId"] as? String, "var-1")
        XCTAssertEqual(json.count, 2)
    }

    // MARK: - AnalyticsEventRequestBody

    func test_analyticsEventRequestBody_encodesAllKeys() throws {
        let auxData = TimelineOpenedAuxData(
            externalUserId: nil,
            userAgent: "iOS/17.0",
            parentUrl: ""
        )

        let body = AnalyticsEventRequestBody(
            name: .timelineOpened,
            userId: "user-123",
            sessionId: "session-456",
            auxData: auxData
        )

        let json = try encodeToDictionary(body)

        XCTAssertEqual(json["name"] as? String, "TimelineOpened")
        XCTAssertEqual(json["userId"] as? String, "user-123")
        XCTAssertEqual(json["sessionId"] as? String, "session-456")
        XCTAssertNotNil(json["auxData"] as? [String: Any])
        XCTAssertEqual(json.count, 4)
    }

    // MARK: - PollVotedRequestBody

    func test_pollVotedRequestBody_encodesAllKeys() throws {
        let auxData = PollVotedAuxData(
            brandName: "Brand",
            campaignName: "Campaign",
            externalUserId: "ext-1",
            parentUrl: "",
            position: 0,
            questionId: "q-1",
            userAgent: "iOS/17.0"
        )

        let body = PollVotedRequestBody(
            name: .timelinePollVoted,
            userId: "user-123",
            sessionId: "session-456",
            pollId: "poll-789",
            pollAnswer: "Option A",
            auxData: auxData
        )

        let json = try encodeToDictionary(body)

        XCTAssertEqual(json["name"] as? String, "TimelinePollVoted")
        XCTAssertEqual(json["pollId"] as? String, "poll-789")
        XCTAssertEqual(json["pollAnswer"] as? String, "Option A")
        XCTAssertEqual(json.count, 6)
    }

    // MARK: - ProductClickedRequestBody

    func test_productClickedRequestBody_encodesAllKeys() throws {
        let auxData = ProductClickedAuxData(
            id: "p1", name: "Product", description: "", externalURL: "",
            imageURL: "", price: "$10", isCatalog: false,
            brandName: "Brand", campaignName: "Campaign", customProducts: [],
            externalUserId: "ext-1", parentUrl: "", position: 0,
            terrificClickId: "click-1", userAgent: "iOS/17.0"
        )

        let items = [ProductClickedItem(productId: "ext-1", variantId: "var-1")]

        let body = ProductClickedRequestBody(
            name: .timelineProductClicked,
            userId: "user-123",
            sessionId: "session-456",
            items: items,
            itemViewSource: "featuredItem",
            auxData: auxData
        )

        let json = try encodeToDictionary(body)

        XCTAssertEqual(json["name"] as? String, "TimelineProductClicked")
        XCTAssertEqual(json["itemViewSource"] as? String, "featuredItem")
        XCTAssertEqual((json["items"] as? [Any])?.count, 1)
        XCTAssertEqual(json.count, 6)
    }

    // MARK: - Request Properties

    func test_analyticsEventAPIRequest_hasCorrectMethod() {
        let body = AnalyticsEventRequestBody(
            name: .timelineOpened,
            userId: "u1",
            sessionId: "s1",
            auxData: TimelineOpenedAuxData(externalUserId: nil, userAgent: "", parentUrl: "")
        )

        let request = AnalyticsEventAPIRequest(storeId: "store-1", requestBody: body)

        XCTAssertEqual(request.method, .post)
    }

    func test_analyticsEventAPIRequest_hasCorrectPath() {
        let body = AnalyticsEventRequestBody(
            name: .timelineOpened,
            userId: "u1",
            sessionId: "s1",
            auxData: TimelineOpenedAuxData(externalUserId: nil, userAgent: "", parentUrl: "")
        )

        let request = AnalyticsEventAPIRequest(storeId: "store-1", requestBody: body)

        XCTAssertEqual(request.path, "/userEvents")
    }

    func test_analyticsEventAPIRequest_hasCorrectHeaders() {
        let body = AnalyticsEventRequestBody(
            name: .timelineOpened,
            userId: "u1",
            sessionId: "s1",
            auxData: TimelineOpenedAuxData(externalUserId: nil, userAgent: "", parentUrl: "")
        )

        let request = AnalyticsEventAPIRequest(storeId: "store-123", requestBody: body)

        let headers = request.headers?.headers
        XCTAssertEqual(headers?["Accept"], "application/json")
        XCTAssertEqual(headers?["Content-Type"], "application/json")
        XCTAssertEqual(headers?["terrific-store-id"], "store-123")
    }

    func test_pollVotedAPIRequest_hasCorrectMethodAndPath() {
        let auxData = PollVotedAuxData(
            brandName: nil, campaignName: nil, externalUserId: nil,
            parentUrl: "", position: 0, questionId: "q1", userAgent: ""
        )
        let body = PollVotedRequestBody(
            name: .timelinePollVoted, userId: "u1", sessionId: "s1",
            pollId: "p1", pollAnswer: "A", auxData: auxData
        )

        let request = PollVotedAPIRequest(storeId: "store-1", requestBody: body)

        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.path, "/userEvents")
    }

    func test_productClickedAPIRequest_hasCorrectMethodAndPath() {
        let auxData = ProductClickedAuxData(
            id: "p1", name: "", description: "", externalURL: "",
            imageURL: "", price: "", isCatalog: false,
            brandName: nil, campaignName: nil, customProducts: [],
            externalUserId: nil, parentUrl: "", position: 0,
            terrificClickId: "", userAgent: ""
        )
        let body = ProductClickedRequestBody(
            name: .timelineProductClicked, userId: "u1", sessionId: "s1",
            items: [], itemViewSource: "featuredItem", auxData: auxData
        )

        let request = ProductClickedAPIRequest(storeId: "store-1", requestBody: body)

        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.path, "/userEvents")
    }

    // MARK: - Full JSON Encoding Round-Trip

    func test_fullEventBody_encodesNestedAuxDataCorrectly() throws {
        let product = AnalyticCustomProduct(
            name: "Shirt", price: "$29.99", currency: "USD",
            description: "Cotton shirt", externalURL: "https://shop.com/shirt"
        )

        let auxData = AssetViewStartedAuxData(
            assetType: "video",
            brandName: "TestBrand",
            campaignName: "Summer2026",
            customProducts: [product],
            externalUserId: "ext-user",
            fixedPosition: 1,
            parentUrl: "",
            position: 1,
            products: [AnalyticProduct(id: "p1", sku: "SK1", categories: [], tags: [])]
        )

        let body = AnalyticsEventRequestBody(
            name: .timelineAssetViewStarted,
            userId: "user-abc",
            sessionId: "carousel-1~asset-1",
            auxData: auxData
        )

        let json = try encodeToDictionary(body)
        let nestedAux = json["auxData"] as? [String: Any]

        XCTAssertNotNil(nestedAux)
        XCTAssertEqual(nestedAux?["assetType"] as? String, "video")

        let products = nestedAux?["customProducts"] as? [[String: Any]]
        XCTAssertEqual(products?.count, 1)
        XCTAssertEqual(products?.first?["name"] as? String, "Shirt")
        XCTAssertEqual(products?.first?["currency"] as? String, "USD")
    }
}
