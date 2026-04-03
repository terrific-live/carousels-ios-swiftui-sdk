//
//  MediaContentView.swift
//  MediaPlayback
//

#if canImport(UIKit)
import SwiftUI

// MARK: - View
public struct MediaContentView<ImageContent: View>: View {

    private let fadeInOutAnimationDuration: TimeInterval = 0.4

    // MARK: - Inputs
    let imageContent: (CGSize) -> ImageContent
    let videoURL: URL?
    let configuration: VideoPreviewConfiguration
    let isSelected: Bool
    let onVideoFinished: (() -> Void)?
    let onVideoProgress: ((Double) -> Void)?
    @Binding var isMuted: Bool

    // MARK: - State
    @StateObject
    private var viewModel = MediaPlayerViewModel()

    // MARK: - Init
    public init(
        videoURL: URL?,
        configuration: VideoPreviewConfiguration = .timelineCard,
        isSelected: Bool = false,
        isMuted: Binding<Bool> = .constant(true),
        onVideoFinished: (() -> Void)? = nil,
        onVideoProgress: ((Double) -> Void)? = nil,
        @ViewBuilder imageContent: @escaping (CGSize) -> ImageContent
    ) {
        self.imageContent = imageContent
        self.videoURL = videoURL
        self.configuration = configuration
        self.isSelected = isSelected
        self._isMuted = isMuted
        self.onVideoFinished = onVideoFinished
        self.onVideoProgress = onVideoProgress
    }

    // MARK: - Body
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                buildImageLayer(size: geo.size)

                buildVideoLayer()
                    .opacity(viewModel.isPlaying ? 1 : 0)

                buildLoadingOverlay()
            }
            .animation(.easeInOut(duration: fadeInOutAnimationDuration), value: viewModel.isPlaying)
        }
        // Only load video when selected to avoid memory bloat from multiple video buffers
        .onChange(of: isSelected) { _, selected in
            handleSelectionChange(selected)
        }
        .onAppear {
            handleOnAppear()
        }
        .onDisappear {
            handleOnDisappear()
        }
        .onReceive(viewModel.videoFinishedPublisher) {
            onVideoFinished?()
        }
        .onChange(of: viewModel.progress) { _, newProgress in
            onVideoProgress?(newProgress)
        }
        .onChange(of: isMuted) { _, newValue in
            viewModel.isMuted = newValue
        }
    }
}

// MARK: - UI Components (Factories)
private extension MediaContentView {

    func buildImageLayer(size: CGSize) -> some View {
        imageContent(size)
    }

    @ViewBuilder
    func buildVideoLayer() -> some View {
        if viewModel.showVideo, let player = viewModel.player {
            OptimizedVideoPlayer(player: player)
        }
    }

    @ViewBuilder
    func buildLoadingOverlay() -> some View {
        if viewModel.isLoading && isSelected {
            ZStack {
                Color.black.opacity(0.3)

                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)

                    Text("Loading video...")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
            }
            .transition(.opacity)
        }
    }
}

// MARK: - Logic & Actions
private extension MediaContentView {

    func handleOnAppear() {
        viewModel.isMuted = isMuted
        guard videoURL != nil, isSelected else { return }
        log("handleOnAppear -> handleLoad + handleStartPlayback")
        // Load video only when selected and appearing
        viewModel.handleLoad(url: videoURL, configuration: configuration)
        viewModel.handleStartPlayback()
    }

    func handleSelectionChange(_ selected: Bool) {
        log("========================================")
        log("isSelected changed: -> \(selected)")
        log("========================================")

        if selected {
            guard videoURL != nil else { return }
            log("✅ selected -> handleLoad + handleStartPlayback")
            // Load video only when selected to avoid memory bloat
            viewModel.handleLoad(url: videoURL, configuration: configuration)
            viewModel.handleStartPlayback()
        } else {
            log("❌ deselected -> handleCleanup (release video buffer)")
            // Cleanup to release AVPlayer buffer and free memory
            viewModel.handleCleanup()
        }
    }

    func handleOnDisappear() {
        log("onDisappear -> handleCleanup (release video buffer)")
        // Always cleanup on disappear to free memory
        viewModel.handleCleanup()
    }

    func log(_ message: String) {
        logMediaPlayback("[MediaContent] [ViewModel: \(viewModel.instanceId)] \(message)")
    }
}

#endif
