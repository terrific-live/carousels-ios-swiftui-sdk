//
//  CarouselFactory.swift
//  TerrificCarouselSDK
//
//  Internal factory for creating carousel dependencies.
//  SDK consumers only get production implementations.
//

import Foundation

// MARK: - CarouselFactory
/// Internal factory for creating carousel dependencies.
/// SDK consumers only get production implementations.
@MainActor
final class CarouselFactory {

    // MARK: - Configuration
    private let configuration: APIConfiguration

    // MARK: - Lazy Dependencies

    private lazy var timelineClient: TimelineClient = {
        TimelineClient.live(configuration: configuration)
    }()

    private lazy var userIdentifierStorage: UserIdentifierStorage = {
        UserDefaultsUserIdentifierStorage()
    }()

    private var terrificUserId: String {
        userIdentifierStorage.userId
    }

    private lazy var analyticsClient: AnalyticsClient = {
        AnalyticsClient.live(configuration: analyticsConfiguration)
    }()

    private var analyticsConfiguration: AnalyticsConfiguration {
        .production(apiConfig: configuration, terrificUserId: terrificUserId)
    }

    // MARK: - Init

    init(configuration: APIConfiguration) {
        self.configuration = configuration
    }

    // MARK: - Service Factories

    private func makeFeedService() -> TimelineService {
        TimelineFeedService(
            client: timelineClient.client,
            configuration: configuration,
            terrificUserId: terrificUserId
        )
    }

    private func makeDetailService() -> TimelineService {
        TimelineDetailService(
            client: timelineClient.client,
            configuration: configuration,
            terrificUserId: terrificUserId
        )
    }

    private func makePollService() -> PollService {
        PollServiceImpl(
            client: timelineClient.client,
            configuration: configuration,
            terrificUserId: terrificUserId
        )
    }

    private func makeAnalyticsService() -> AnalyticsService {
        AnalyticsServiceImpl(
            client: analyticsClient.client,
            configuration: analyticsConfiguration
        )
    }

    private func makePollAnswerStorage() -> PollAnswerStorage {
        UserDefaultsPollAnswerStorage()
    }

    private func makeLikeStorage() -> LikeStorage {
        UserDefaultsLikeStorage()
    }

    // MARK: - Coordinator Factory

    /// Creates a TimelineCoordinator with production dependencies
    func makeTimelineCoordinator(
        carouselId: String? = nil,
        onAnalyticsEvent: ((CarouselAnalyticsEvent) -> Void)? = nil
    ) -> TimelineCoordinator {
        TimelineCoordinator(
            feedService: makeFeedService(),
            detailService: makeDetailService(),
            pollService: makePollService(),
            answerStorage: makePollAnswerStorage(),
            likeStorage: makeLikeStorage(),
            analyticsService: makeAnalyticsService(),
            carouselId: carouselId ?? configuration.carouselId,
            onAnalyticsEvent: onAnalyticsEvent
        )
    }
}
