//
//  AnalyticsServiceImpl+Timeline.swift
//  TerrificCarouselSDK
//

import Foundation

// MARK: - Timeline Events
extension AnalyticsServiceImpl {

    func trackTimelineOpened(
        carouselId: String,
        parentUrl: String,
        externalUserId: String?
    ) async throws {
        let sessionId = carouselId

        let auxData = TimelineOpenedAuxData(
            externalUserId: externalUserId,
            userAgent: configuration.userAgent,
            parentUrl: ""
        )

        let body = AnalyticsEventRequestBody(
            name: .timelineOpened,
            userId: configuration.userId,
            sessionId: sessionId,
            auxData: auxData
        )

        let request = AnalyticsEventAPIRequest(
            storeId: configuration.storeId,
            requestBody: body
        )

        let _ = try await client.send(request)
    }

    func trackTimelineClosed(
        carouselId: String,
        parentUrl: String,
        totalOpenDurationMs: Int,
        activeViewDurationMs: Int,
        externalUserId: String?
    ) async throws {
        let sessionId = carouselId

        let auxData = TimelineClosedAuxData(
            activeViewDurationMs: activeViewDurationMs,
            externalUserId: externalUserId,
            parentUrl: "",
            totalOpenDurationMs: totalOpenDurationMs
        )

        let body = AnalyticsEventRequestBody(
            name: .timelineClosed,
            userId: configuration.userId,
            sessionId: sessionId,
            auxData: auxData
        )

        let request = AnalyticsEventAPIRequest(
            storeId: configuration.storeId,
            requestBody: body
        )

        let _ = try await client.send(request)
    }
}
