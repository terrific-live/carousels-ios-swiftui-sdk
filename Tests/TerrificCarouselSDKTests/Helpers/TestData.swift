//
//  TestData.swift
//  TerrificCarouselSDKTests
//

import Foundation
@testable import TerrificCarouselSDK

// MARK: - Sample TimelineAssetDTO
extension TimelineAssetDTO {
    static func sample(
        id: String = "asset-1",
        name: String? = "Test Asset",
        title: String? = "Test Title",
        description: String? = "Test Description",
        type: AssetMediaTypeDTO = .image,
        position: Int = 0,
        timestamp: String? = "2026-01-15T10:30:00Z",
        media: AssetMediaDTO? = .sample,
        ctaButton: AssetCTAButtonDTO? = nil,
        products: [ProductDTO]? = nil,
        pollData: PollDTO? = nil
    ) -> TimelineAssetDTO {
        TimelineAssetDTO(
            id: id,
            name: name,
            title: title,
            description: description,
            type: type,
            position: position,
            timestamp: timestamp,
            media: media,
            background: nil,
            brandLogo: nil,
            ctaButton: ctaButton,
            products: products,
            pollData: pollData,
            brandName: nil,
            campaignName: nil
        )
    }

    static func sampleVideo(
        id: String = "video-1",
        position: Int = 0
    ) -> TimelineAssetDTO {
        .sample(
            id: id,
            title: "Video Asset",
            type: .video,
            position: position
        )
    }

    static func samplePoll(
        id: String = "poll-1",
        position: Int = 0
    ) -> TimelineAssetDTO {
        .sample(
            id: id,
            title: "Poll Asset",
            type: .poll,
            position: position,
            pollData: .sample
        )
    }

    static func sampleWithCTA(
        id: String = "cta-1",
        position: Int = 0,
        url: String = "https://example.com"
    ) -> TimelineAssetDTO {
        .sample(
            id: id,
            title: "CTA Asset",
            position: position,
            ctaButton: AssetCTAButtonDTO(
                color: "#FFFFFF",
                position: "bottom",
                text: "Click Me",
                textColor: "#000000",
                url: url
            )
        )
    }
}

// MARK: - Sample AssetMediaDTO
extension AssetMediaDTO {
    static let sample = AssetMediaDTO(
        coverUrl: "https://example.com/cover.jpg",
        desktopUrl: "https://example.com/desktop.jpg",
        mobileUrl: "https://example.com/mobile.jpg",
        srcUrl: nil,
        videoPreviewUrl: nil
    )
}

// MARK: - Sample PollDTO
extension PollDTO {
    static let sample = PollDTO(
        id: "poll-1",
        question: "What is your favorite color?",
        questionId: "q-1",
        options: [
            PollOptionDTO(text: "Red", numberOfVotes: 10),
            PollOptionDTO(text: "Blue", numberOfVotes: 20),
            PollOptionDTO(text: "Green", numberOfVotes: 15)
        ]
    )
}

// MARK: - Sample PollData
extension PollData {
    static let sample = PollData(
        id: "poll-1",
        questionId: "q-1",
        question: "What is your favorite color?",
        options: [
            PollOptionData(id: 0, text: "Red", numberOfVotes: 10),
            PollOptionData(id: 1, text: "Blue", numberOfVotes: 20),
            PollOptionData(id: 2, text: "Green", numberOfVotes: 15)
        ]
    )

    static func sample(
        id: String = "poll-1",
        questionId: String = "q-1",
        question: String = "Test Question?",
        options: [PollOptionData] = [
            PollOptionData(id: 0, text: "Option A", numberOfVotes: 5),
            PollOptionData(id: 1, text: "Option B", numberOfVotes: 10)
        ]
    ) -> PollData {
        PollData(
            id: id,
            questionId: questionId,
            question: question,
            options: options
        )
    }
}

// MARK: - Sample TimelineServiceResult
extension TimelineServiceResult {
    static func sample(
        assets: [TimelineAssetDTO] = [.sample()],
        carouselConfig: CarouselConfigDTO? = nil,
        anchor: String? = nil
    ) -> TimelineServiceResult {
        TimelineServiceResult(
            assets: assets,
            carouselConfig: carouselConfig,
            anchor: anchor
        )
    }
}

// MARK: - Sample Assets List
extension Array where Element == TimelineAssetDTO {
    static func samplePage(count: Int = 10, startPosition: Int = 0) -> [TimelineAssetDTO] {
        (0..<count).map { index in
            TimelineAssetDTO.sample(
                id: "asset-\(startPosition + index)",
                title: "Asset \(startPosition + index)",
                position: startPosition + index
            )
        }
    }
}
