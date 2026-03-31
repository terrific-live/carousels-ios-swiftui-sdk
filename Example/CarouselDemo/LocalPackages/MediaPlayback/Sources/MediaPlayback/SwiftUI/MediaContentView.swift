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
        // Inject data into viewModel when either videoURL or configuration changes.
        .task(id: LoadIdentifier(url: videoURL, configuration: configuration)) {
            viewModel.handleLoad(url: videoURL, configuration: configuration)
        }
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
        log("handleOnAppear")
        viewModel.handleStartPlayback()
    }

    func handleSelectionChange(_ selected: Bool) {
        guard videoURL != nil else { return }
        log("========================================")
        log("isSelected changed: -> \(selected)")
        log("========================================")

        if selected {
            log("✅ selected -> handleStartPlayback")
            viewModel.handleStartPlayback()
        } else {
            log("❌ deselected -> handleStopPlayback")
            viewModel.handleStopPlayback()
        }
    }

    func handleOnDisappear() {
        log("onDisappear")
        if isSelected {
            log("onDisappear -> handleStopPlayback")
            viewModel.handleStopPlayback()
        }
    }

    func log(_ message: String) {
        logMediaPlayback("[MediaContent] [ViewModel: \(viewModel.instanceId)] \(message)")
    }
}

// MARK: - Task Identifier
/// Combines URL and configuration for single .task(id:) instead of duplicate tasks
private struct LoadIdentifier: Equatable {
    let url: URL?
    let configuration: VideoPreviewConfiguration
}
#endif
