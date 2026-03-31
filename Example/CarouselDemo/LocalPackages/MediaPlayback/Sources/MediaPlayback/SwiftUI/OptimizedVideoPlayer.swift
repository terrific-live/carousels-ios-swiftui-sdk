//
//  OptimizedVideoPlayer.swift
//  MediaPlayback
//

#if canImport(UIKit)
import SwiftUI
import AVKit

public struct OptimizedVideoPlayer: UIViewControllerRepresentable {
    public let player: AVPlayer

    public init(player: AVPlayer) {
        self.player = player
    }

    public func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player

        // 1. Hide Native Controls (since you have your own UI)
        controller.showsPlaybackControls = false

        // 2. Set Video Gravity (Aspect Fill)
        controller.videoGravity = .resizeAspectFill

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
        // Only update if the reference changes to avoid glitches
        if uiViewController.player != player {
            uiViewController.player = player
        }
    }
}
#endif
