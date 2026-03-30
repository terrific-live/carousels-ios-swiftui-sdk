//
//  TimelineService.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 14.01.2026.
//

import Foundation

// MARK: - TimelineServiceResult
/// Result containing assets and optional carousel configuration
struct TimelineServiceResult {
    let assets: [TimelineAssetDTO]
    let carouselConfig: CarouselConfigDTO?
}

// MARK: - TimelineService Protocol
protocol TimelineService {
    /// Fetches assets for a carousel with pagination support.
    /// - Parameters:
    ///   - carouselId: The carousel identifier
    ///   - page: Page number (0-based)
    ///   - itemsPerPage: Number of items per page
    ///   - offset: Starting offset in the carousel (default 0)
    /// - Returns: Result containing assets and carousel configuration
    func fetchAssets(
        for carouselId: String,
        page: Int,
        itemsPerPage: Int,
        offset: Int
    ) async throws -> TimelineServiceResult
}

// MARK: - Default Implementation
extension TimelineService {
    /// Convenience method with default offset of 0
    func fetchAssets(
        for carouselId: String,
        page: Int,
        itemsPerPage: Int
    ) async throws -> TimelineServiceResult {
        try await fetchAssets(
            for: carouselId,
            page: page,
            itemsPerPage: itemsPerPage,
            offset: 0
        )
    }
}
