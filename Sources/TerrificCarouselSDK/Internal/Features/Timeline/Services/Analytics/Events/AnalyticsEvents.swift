//
//  AnalyticsEvents.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 16.03.2026.
//

import Foundation

// MARK: - AnalyticsEventName
enum AnalyticsEventName: String, Encodable {
    case timelineOpened = "TimelineOpened"
    case timelineClosed = "TimelineClosed"
    case timelineAssetViewStarted = "TimelineAssetViewStarted"
    case timelineAssetViewEnded = "TimelineAssetViewEnded"
    case timelineAssetLiked = "TimelineAssetLiked"
    case timelineCarouselLoaded = "TimelineCarouselLoaded"
    case timelineCarouselViewed = "TimelineCarouselViewed"
    case timelineCarouselAssetViewed = "TimelineCarouselAssetViewed"
    case timelineCarouselClicked = "TimelineCarouselClicked"
    case timelineCTAButtonClicked = "TimelineCTAButtonClicked"
    case timelineAssetShared = "TimelineAssetShared"
    case timelinePollVoted = "TimelinePollVoted"
    case timelineProductClicked = "TimelineProductClicked"
}
