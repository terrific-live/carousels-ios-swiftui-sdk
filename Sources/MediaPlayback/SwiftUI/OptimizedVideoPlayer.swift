//
//  OptimizedVideoPlayer.swift
//  MediaPlayback
//

#if canImport(UIKit)
import SwiftUI
import AVKit

public struct OptimizedVideoPlayer: UIViewControllerRepresentable {
    public let player: AVPlayer
    public var containerSize: CGSize

    public init(player: AVPlayer, containerSize: CGSize = .zero) {
        self.player = player
        self.containerSize = containerSize
    }

    public func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player

        // 1. Hide Native Controls (since you have your own UI)
        controller.showsPlaybackControls = false

        // 2. Set Video Gravity
        controller.videoGravity = resolvedVideoGravity

        // 3. Set Background Color to black (to prevent white flashes)
        controller.view.backgroundColor = .clear

        // 4. CRITICAL FIX: Disable Live Text / Subject Lifting
        // This stops the VisionKit log spam and reduces CPU usage.
        if #available(iOS 16.0, *) {
            controller.allowsVideoFrameAnalysis = false
        }

        return controller
    }

    public func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if uiViewController.player != player {
            uiViewController.player = player
        }
        // Update video gravity when orientation changes (iPad landscape fix)
        uiViewController.videoGravity = resolvedVideoGravity
    }

    /// iPad landscape: use .resizeAspect to preserve natural aspect ratio
    /// (avoids distortion from the vertical-scroll rotation hack).
    /// All other cases: .resizeAspectFill for full-bleed video.
    private var resolvedVideoGravity: AVLayerVideoGravity {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        let isLandscape = containerSize.width > containerSize.height
        return (isIPad && isLandscape) ? .resizeAspect : .resizeAspectFill
    }
}
#endif
