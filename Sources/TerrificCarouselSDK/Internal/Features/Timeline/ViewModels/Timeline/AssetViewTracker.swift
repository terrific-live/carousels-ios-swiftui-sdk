//
//  AssetViewTracker.swift
//  TerrificCarouselSDK
//

import Foundation

// MARK: - AssetViewTracker
/// Tracks the duration of individual asset views, accounting for background time.
struct AssetViewTracker {

    // MARK: - State
    private(set) var startTime: Date?
    private(set) var assetIndex: Int?
    private(set) var backgroundDuration: TimeInterval = 0

    var isTracking: Bool { startTime != nil }

    // MARK: - Actions

    mutating func start(at index: Int) {
        startTime = Date()
        assetIndex = index
        backgroundDuration = 0
    }

    /// Ends tracking and returns the measured durations, or nil if not tracking.
    mutating func end() -> (index: Int, viewDurationMs: Int, netoWatchTimeMs: Int)? {
        guard let startTime, let assetIndex else { return nil }

        let viewDurationMs = Int(Date().timeIntervalSince(startTime) * 1000)
        let netoWatchTimeMs = max(0, viewDurationMs - Int(backgroundDuration * 1000))

        self.startTime = nil
        self.assetIndex = nil
        self.backgroundDuration = 0

        return (assetIndex, viewDurationMs, netoWatchTimeMs)
    }

    mutating func addBackgroundTime(_ interval: TimeInterval) {
        guard isTracking else { return }
        backgroundDuration += interval
    }
}
