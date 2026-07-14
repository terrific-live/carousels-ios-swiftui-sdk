//
//  DetailSessionTracker.swift
//  TerrificCarouselSDK
//

import Foundation

// MARK: - DetailSessionTracker
/// Tracks the duration of the detail view session, accounting for background time.
struct DetailSessionTracker {

    // MARK: - State
    private(set) var openedTime: Date?
    private(set) var backgroundDuration: TimeInterval = 0

    var isTracking: Bool { openedTime != nil }

    // MARK: - Actions

    mutating func open() {
        openedTime = Date()
        backgroundDuration = 0
    }

    /// Closes the session and returns the measured durations, or nil if not tracking.
    mutating func close() -> (totalOpenDurationMs: Int, activeViewDurationMs: Int)? {
        guard let openedTime else { return nil }

        let totalOpenDurationMs = Int(Date().timeIntervalSince(openedTime) * 1000)
        let activeViewDurationMs = max(0, totalOpenDurationMs - Int(backgroundDuration * 1000))

        self.openedTime = nil
        self.backgroundDuration = 0

        return (totalOpenDurationMs, activeViewDurationMs)
    }

    mutating func addBackgroundTime(_ interval: TimeInterval) {
        guard isTracking else { return }
        backgroundDuration += interval
    }
}
