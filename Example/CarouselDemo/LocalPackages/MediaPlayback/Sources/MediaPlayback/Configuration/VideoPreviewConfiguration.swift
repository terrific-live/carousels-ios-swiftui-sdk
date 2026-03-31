//
//  VideoPreviewConfiguration.swift
//  MediaPlayback
//

import Foundation

// MARK: - VideoPreviewConfiguration
public struct VideoPreviewConfiguration: Equatable, Sendable {

    // MARK: - Mode

    /// Determines which controller to use
    public let playbackMode: PlaybackMode

    // MARK: - Preview Timing

    /// Delay before the video becomes visible
    public let showDelay: TimeInterval

    /// How long the preview is allowed to play
    /// `.infinity` means no automatic stop
    public let maxPlaybackDuration: TimeInterval

    /// Whether preview should automatically restart
    public let shouldLoopPreview: Bool

    // MARK: - Playback Behavior

    public let playback: PlaybackBehavior

    // MARK: - Init

    public init(
        playbackMode: PlaybackMode = .preview,
        showDelay: TimeInterval = 0,
        maxPlaybackDuration: TimeInterval = .infinity,
        shouldLoopPreview: Bool = false,
        playback: PlaybackBehavior = .loop
    ) {
        self.playbackMode = playbackMode
        self.showDelay = showDelay
        self.maxPlaybackDuration = maxPlaybackDuration
        self.shouldLoopPreview = shouldLoopPreview
        self.playback = playback
    }
}

// MARK: - Preset Configurations
public extension VideoPreviewConfiguration {

    static let timelineCard = VideoPreviewConfiguration(
        playbackMode: .preview,
        showDelay: 2.5,
        maxPlaybackDuration: 5.0,
        shouldLoopPreview: false,
        playback: .restartOnPreview
    )

    static let fullScreen = VideoPreviewConfiguration(
        playbackMode: .fullScreen,
        showDelay: 0,
        maxPlaybackDuration: .infinity,
        shouldLoopPreview: false,
        playback: .loop
    )

    /// Full screen mode that plays once and stops (for auto-advance scenarios)
    static let fullScreenPlayOnce = VideoPreviewConfiguration(
        playbackMode: .fullScreen,
        showDelay: 0,
        maxPlaybackDuration: .infinity,
        shouldLoopPreview: false,
        playback: .playOnce
    )
}

// MARK: - Types
public enum PlaybackBehavior: Equatable, Sendable {
    /// Play once and stop at the end
    case playOnce

    /// Loop the entire video
    case loop

    /// Play from the beginning every time preview starts
    case restartOnPreview
}

public enum PlaybackMode: Equatable, Sendable {
    /// Preview mode (delay, duration, optional loop)
    case preview

    /// Full-screen mode (immediate, infinite loop)
    case fullScreen
}

// MARK: - Types for future use
public enum VisibilityBehavior: Equatable, Sendable {
    /// Playback is fully controlled externally
    case manual

    /// Auto-play / pause based on visibility percentage
    case autoPlay(threshold: Double)
}

public struct AudioBehavior: Equatable, Sendable {
    public let isMuted: Bool

    public init(isMuted: Bool) {
        self.isMuted = isMuted
    }
}

public struct AnalyticsBehavior: Equatable, Sendable {
    public let shouldTrack: Bool

    public init(shouldTrack: Bool) {
        self.shouldTrack = shouldTrack
    }
}
