//
//  DebugConfiguration.swift
//  TerrificCarouselSDK
//

import HTTPClient
import MediaPlayback

/// Debug configuration for TerrificCarouselSDK
public enum CarouselDebugConfiguration {
    /// Enable HTTP client logging (CURL and response logging)
    /// Set to `true` to see network requests in console
    public static var isHTTPLoggingEnabled: Bool {
        get { HTTPClientLogger.isEnabled }
        set { HTTPClientLogger.isEnabled = newValue }
    }

    /// Enable video playback logging
    /// Set to `true` to see video player events in console
    public static var isVideoLoggingEnabled: Bool {
        get { MediaPlaybackLogger.isEnabled }
        set { MediaPlaybackLogger.isEnabled = newValue }
    }
}
