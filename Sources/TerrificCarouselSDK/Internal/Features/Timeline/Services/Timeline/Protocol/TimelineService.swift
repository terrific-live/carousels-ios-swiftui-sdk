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
    /// Anchor for cursor-based pagination (contains encoded viewed assets)
    let anchor: String?
}

// MARK: - TimelineService Protocol
protocol TimelineService {
    /// Fetches assets for a carousel with pagination support.
    /// - Parameters:
    ///   - carouselId: The carousel identifier
    ///   - page: Page number (0-based)
    ///   - itemsPerPage: Number of items per page
    ///   - offset: Starting offset in the carousel (default 0)
    ///   - anchor: Cursor anchor from previous response (nil for first page)
    ///   - startAssetId: Asset ID to start from (for detail view)
    /// - Returns: Result containing assets, carousel configuration, and anchor for next page
    func fetchAssets(
        for carouselId: String,
        page: Int,
        itemsPerPage: Int,
        offset: Int,
        anchor: String?,
        startAssetId: String?
    ) async throws -> TimelineServiceResult
}

// MARK: - Default Implementation
extension TimelineService {
    /// Convenience method with default offset and no anchor
    func fetchAssets(
        for carouselId: String,
        page: Int,
        itemsPerPage: Int
    ) async throws -> TimelineServiceResult {
        try await fetchAssets(
            for: carouselId,
            page: page,
            itemsPerPage: itemsPerPage,
            offset: 0,
            anchor: nil,
            startAssetId: nil
        )
    }

    /// Convenience method with offset but no anchor
    func fetchAssets(
        for carouselId: String,
        page: Int,
        itemsPerPage: Int,
        offset: Int
    ) async throws -> TimelineServiceResult {
        try await fetchAssets(
            for: carouselId,
            page: page,
            itemsPerPage: itemsPerPage,
            offset: offset,
            anchor: nil,
            startAssetId: nil
        )
    }

    /// Convenience method with offset and anchor but no startAssetId
    func fetchAssets(
        for carouselId: String,
        page: Int,
        itemsPerPage: Int,
        offset: Int,
        anchor: String?
    ) async throws -> TimelineServiceResult {
        try await fetchAssets(
            for: carouselId,
            page: page,
            itemsPerPage: itemsPerPage,
            offset: offset,
            anchor: anchor,
            startAssetId: nil
        )
    }
}
