//
//  ErrorLoggingServiceImpl.swift
//  TerrificCarouselSDK
//

import Foundation
import HTTPClient

// MARK: - ErrorLoggingServiceImpl
/// Implementation of ErrorLoggingService with batching and throttling
actor ErrorLoggingServiceImpl: ErrorLoggingService {

    // MARK: - Constants
    private static let throttleInterval: TimeInterval = 0.3 // 300ms
    private static let userId = "anonymous"

    // MARK: - Dependencies
    private let client: Client
    private let configuration: ErrorLoggingConfiguration

    // MARK: - State
    private var pendingEntries: [ErrorLogEntry] = []
    private var throttleTask: Task<Void, Never>?

    // MARK: - Init
    init(client: Client, configuration: ErrorLoggingConfiguration) {
        self.client = client
        self.configuration = configuration
    }

    // MARK: - ErrorLoggingService

    nonisolated func logError(
        message: String,
        severity: ErrorSeverity,
        route: ErrorRoute,
        metadata: [String: String]?
    ) {
        let entry = ErrorLogEntry(
            message: message,
            severity: severity.rawValue,
            project: configuration.project,
            route: route.rawValue,
            timestamp: ISO8601DateFormatter().string(from: Date()),
            metadata: metadata
        )

        Task {
            await enqueueAndScheduleFlush(entry)
        }
    }

    // MARK: - Private

    private func enqueueAndScheduleFlush(_ entry: ErrorLogEntry) {
        pendingEntries.append(entry)
        scheduleFlush()
    }

    private func scheduleFlush() {
        guard throttleTask == nil else { return }

        throttleTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(Self.throttleInterval * 1_000_000_000))

            guard !Task.isCancelled else { return }

            await self?.flush()
        }
    }

    private func flush() async {
        let entriesToSend = pendingEntries
        pendingEntries = []
        throttleTask = nil

        guard !entriesToSend.isEmpty else { return }

        let requestBody = ErrorLogRequestBody(
            userId: Self.userId,
            entries: entriesToSend
        )

        let request = ErrorLogAPIRequest(requestBody: requestBody)

        do {
            _ = try await client.send(request)
        } catch {
            #if DEBUG
            print("[ErrorLogging] Failed to send error log: \(error)")
            #endif
        }
    }
}
