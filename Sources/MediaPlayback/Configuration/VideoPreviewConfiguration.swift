//
//  VideoPreviewConfiguration.swift
//  MediaPlayback
//

import Foundation

// MARK: - VideoPreviewConfiguration
public struct VideoPreviewConfiguration: Equatable, Sendable {

    // MARK: - Mode

    /// Determines playback mode (preview vs full-screen)
    public let playbackMode: PlaybackMode

    // MARK: - Playback Behavior

    public let playback: PlaybackBehavior

    // MARK: - Init

    public init(
        playbackMode: PlaybackMode = .preview,
        playback: PlaybackBehavior = .loop
    ) {
        self.playbackMode = playbackMode
        self.playback = playback
    }
}

// MARK: - Preset Configurations
public extension VideoPreviewConfiguration {

    static let timelineCard = VideoPreviewConfiguration(
        playbackMode: .preview,
        playback: .restartOnPreview
    )

    static let fullScreen = VideoPreviewConfiguration(
        playbackMode: .fullScreen,
        playback: .loop
    )

    /// Full screen mode that plays once and stops (for auto-advance scenarios)
    static let fullScreenPlayOnce = VideoPreviewConfiguration(
        playbackMode: .fullScreen,
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
    /// Preview mode
    case preview

    /// Full-screen mode
    case fullScreen
}
