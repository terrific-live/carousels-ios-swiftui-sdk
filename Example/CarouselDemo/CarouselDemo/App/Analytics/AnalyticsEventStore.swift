//
//  AnalyticsEventStore.swift
//  CarouselDemo
//

import SwiftUI
import TerrificCarouselSDK

// MARK: - AnalyticsEventItem
struct AnalyticsEventItem: Identifiable {
    let id = UUID()
    let timestamp: Date
    let eventName: String
    let details: String

    init(event: CarouselAnalyticsEvent) {
        self.timestamp = Date()

        switch event {
        case .carouselLoaded(let assets):
            self.eventName = "carouselLoaded"
            self.details = "assets: \(assets.count)"

        case .carouselViewed(let assets):
            self.eventName = "carouselViewed"
            self.details = "assets: \(assets.count)"

        case .carouselClicked(let asset, let position):
            self.eventName = "carouselClicked"
            self.details = "position: \(position), asset: \(asset.id)"

        case .assetViewed(let asset, let position, let isInitialView):
            self.eventName = "assetViewed"
            self.details = "position: \(position), initial: \(isInitialView), asset: \(asset.id)"

        case .assetViewStarted(let asset, let position):
            self.eventName = "assetViewStarted"
            self.details = "position: \(position), asset: \(asset.id)"

        case .assetViewEnded(let asset, let position, let durationMs):
            self.eventName = "assetViewEnded"
            self.details = "position: \(position), duration: \(durationMs)ms"

        case .timelineOpened(let parentUrl):
            self.eventName = "timelineOpened"
            self.details = "url: \(parentUrl)"

        case .timelineClosed(let parentUrl, let durationMs):
            self.eventName = "timelineClosed"
            self.details = "duration: \(durationMs)ms"

        case .assetLiked(let asset):
            self.eventName = "assetLiked"
            self.details = "asset: \(asset.id)"

        case .assetShared(let asset, let position):
            self.eventName = "assetShared"
            self.details = "position: \(position), asset: \(asset.id)"

        case .ctaButtonClicked(let asset, let position, let targetUrl):
            self.eventName = "ctaButtonClicked"
            self.details = "position: \(position), url: \(targetUrl)"

        case .pollVoted(let asset, let position, let pollId, let answer):
            self.eventName = "pollVoted"
            self.details = "position: \(position), pollId: \(pollId), answer: \(answer)"
        }
    }
}

// MARK: - AnalyticsEventStore
internal import Combine
@MainActor
final class AnalyticsEventStore: ObservableObject {
    @Published
    private(set) var events: [AnalyticsEventItem] = []

    func add(_ event: CarouselAnalyticsEvent) {
        let item = AnalyticsEventItem(event: event)
        events.insert(item, at: 0) // newest first

        // Keep only last 50 events
        if events.count > 50 {
            events = Array(events.prefix(50))
        }
    }

    func clear() {
        events.removeAll()
    }
}
