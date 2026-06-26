//
//  FullscreenTimelineAssetCard.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 21.01.2026.
//

import SwiftUI
import ImageLoader
import MediaPlayback

struct TimelineDetailAssetCard: View {

    // MARK: - Environment
    @Environment(\.accessibilityText) private var accessibilityText
    @Environment(\.openURL) private var openURL

    // MARK: - Inputs
    let viewData: TimelineAssetData
    let isSelected: Bool
    let isLiked: Bool
    let displayDuration: TimeInterval
    let sizeConfig: DetailStyleConfiguration
    let sponsorship: SponsorshipDTO?
    let onCtaButtonTap: (() -> Void)?
    let onProductCtaTap: ((ProductData, URL?) -> Void)?
    let onLikeTap: (() -> Void)?
    let onShareTap: (() -> Void)?
    let onVideoFinished: (() -> Void)?
    let onSponsorshipTap: ((_ sponsorshipPlacement: AssetSponsorshipPlacement, _ sponsorshipPosition: SponsorshipPosition?, _ clickPosition: SponsorshipClickPosition?, _ sponsorshipUrl: String?) -> Void)?

    // MARK: - Bindings
    @Binding var isMuted: Bool

    // MARK: - State
    @State private var progress: Double = 0
    @State private var timerTask: Task<Void, Never>?
    @State private var hasValidVideo: Bool = false

    // MARK: - Init
    init(
        viewData: TimelineAssetData,
        isSelected: Bool = true,
        isLiked: Bool = false,
        displayDuration: TimeInterval = 10,
        sizeConfig: DetailStyleConfiguration = .default,
        sponsorship: SponsorshipDTO? = nil,
        isMuted: Binding<Bool> = .constant(true),
        onCtaButtonTap: (() -> Void)? = nil,
        onProductCtaTap: ((ProductData, URL?) -> Void)? = nil,
        onLikeTap: (() -> Void)? = nil,
        onShareTap: (() -> Void)? = nil,
        onVideoFinished: (() -> Void)? = nil,
        onSponsorshipTap: ((_ sponsorshipPlacement: AssetSponsorshipPlacement, _ sponsorshipPosition: SponsorshipPosition?, _ clickPosition: SponsorshipClickPosition?, _ sponsorshipUrl: String?) -> Void)? = nil
    ) {
        self.viewData = viewData
        self.isSelected = isSelected
        self.isLiked = isLiked
        self.displayDuration = displayDuration
        self.sizeConfig = sizeConfig
        self.sponsorship = sponsorship
        self._isMuted = isMuted
        self.onCtaButtonTap = onCtaButtonTap
        self.onProductCtaTap = onProductCtaTap
        self.onLikeTap = onLikeTap
        self.onShareTap = onShareTap
        self.onVideoFinished = onVideoFinished
        self.onSponsorshipTap = onSponsorshipTap
    }

    // MARK: - Sponsor Layout
    private var sponsorLayout: DetailSponsorLayout {
        DetailSponsorLayout(
            sponsorship: sponsorship,
            mediaType: viewData.mediaType,
            sizeConfig: sizeConfig,
            hasCustomBackground: viewData.hasCustomBackground
        )
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: viewData.hasCustomBackground ? sizeConfig.cardSpacing : 0) {
            // Asset Card
            assetCard

            // Products Carousel (detail mode - with price and CTA)
            if !viewData.products.isEmpty {
                ProductCarouselView(
                    products: viewData.products,
                    displayMode: .full,
                    isSelected: isSelected,
                    sizeConfig: sizeConfig.product,
                    onCtaTap: onProductCtaTap
                )
            }
        }
        .padding(viewData.hasCustomBackground ? sizeConfig.edgePadding : 0)
        .background(backgroundView)
        .accessibilityElement(children: .contain)
    }

    // MARK: - Background View
    @ViewBuilder
    private var backgroundView: some View {
        if let backgroundImageURL = viewData.backgroundImageURL {
            // Background image
            CachedAsyncImage(url: backgroundImageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                // Fallback to gradient while loading
                LinearGradient(
                    colors: [viewData.primaryBackgroundColor, viewData.secondaryBackgroundColor],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        } else {
            // Gradient background (default)
            LinearGradient(
                colors: [viewData.primaryBackgroundColor, viewData.secondaryBackgroundColor],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    // MARK: - Asset Card
    private var assetCard: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                // Content based on media type
                switch viewData.mediaType {
                case .poll:
                    pollContent
                case .image, .video, .ad:
                    mediaContent
                }

                // Overlay
                if viewData.mediaType == .poll {
                    pollOverlay
                } else {
                    overlay
                }
            }

            // Progress bar at the bottom
            progressBar
                .padding(.bottom, sponsorLayout.bannerBottomInset)
        }
        .overlay(alignment: sponsorLayout.badgeAlignment) {
            DetailSponsorBadgeOverlay(layout: sponsorLayout, onTap: handleSponsorTap)
        }
        .overlay {
            DetailSponsorBannerOverlay(layout: sponsorLayout, onTap: handleSponsorTap)
        }
        .clipShape(RoundedRectangle(cornerRadius: viewData.hasCustomBackground ? sizeConfig.cardCornerRadius : 0))
        .clipped()
        .onAppear {
            if isSelected {
                startTimerIfNeeded()
            }
        }
        .onChange(of: isSelected) { _, selected in
            handleSelectionChange(selected)
        }
        .onDisappear {
            stopTimer()
        }
    }

    // MARK: - Progress Bar
    @ViewBuilder
    private var progressBar: some View {
        // Hide progress bar for video/ad types until video is actually playing
        // Show progress bar for image and poll types (timer-based)
        if (viewData.mediaType == .video || viewData.mediaType == .ad) && !hasValidVideo {
            EmptyView()
        } else {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: sizeConfig.progressBarHeight)

                    // Progress
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: geometry.size.width * progress, height: sizeConfig.progressBarHeight)
                        .animation(.linear(duration: 0.1), value: progress)
                }
            }
            .frame(height: sizeConfig.progressBarHeight)
        }
    }

    // MARK: - Poll Content
    @ViewBuilder
    private var pollContent: some View {
        if let pollViewModel = viewData.pollViewModel {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    if sponsorLayout.shouldShowPollSponsor && sponsorLayout.pollSponsorPosition == "top" {
                        DetailPollSponsorView(layout: sponsorLayout)
                            .padding(.top, sizeConfig.timestampTopMargin * 3)
                            .onTapGesture {
                                handleSponsorTap(placement: .pollLogo, position: .top, clickPosition: .top, url: sponsorLayout.pollSponsorRedirectUrl)
                            }
                    }
                    Spacer()
                    PollView(
                        viewModel: pollViewModel,
                        sizeConfig: sizeConfig.poll,
                        displayMode: .interactive  // Shows actual state, allows interaction
                    )
                    Spacer()
                    if sponsorLayout.shouldShowPollSponsor && sponsorLayout.pollSponsorPosition == "bottom" {
                        DetailPollSponsorView(layout: sponsorLayout)
                            .padding(.bottom, sizeConfig.bottomInfoPaddingBottom + sizeConfig.progressBarHeight)
                            .onTapGesture {
                                handleSponsorTap(placement: .pollLogo, position: .bottom, clickPosition: .bottom, url: sponsorLayout.pollSponsorRedirectUrl)
                            }
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }

    // MARK: - Poll Overlay (timestamp + action buttons only)
    private var pollOverlay: some View {
        VStack {
            // Top: Timestamp (polls never have sponsor overlays, no inset needed)
            if viewData.showTimestamp {
                timestampLabel
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, sizeConfig.timestampTopMargin)
                    .padding(.horizontal, sizeConfig.timestampHorizontalMargin)
            }

            Spacer()

            // Bottom: Action buttons only (no info section for polls)
            HStack {
                Spacer()
                actionButtons
                    .padding(.trailing, sizeConfig.contentHorizontalPadding)
                    .padding(.bottom, sizeConfig.bottomInfoPaddingBottom)
            }
        }
    }

    // MARK: - Media Content
    @ViewBuilder
    private var mediaContent: some View {
        MediaContentView(
            videoURL: viewData.videoURLForPlayback,
            configuration: .fullScreenPlayOnce,
            isSelected: isSelected,
            isMuted: $isMuted,
            onVideoFinished: onVideoFinished,
            onVideoProgress: { videoProgress in
                // Only update progress from video for video type assets
                if viewData.mediaType == .video {
                    progress = videoProgress
                }
            },
            onVideoValidityChanged: { isValid in
                hasValidVideo = isValid
            },
            imageContent: { size in
                CachedAsyncImage(url: viewData.imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size.width, height: size.height)
                        .clipped()
                } placeholder: {
                    ImageSkeleton()
                        .frame(width: size.width, height: size.height)
                }
            }
        )
        .overlay(
            LinearGradient(
                colors: [.black.opacity(0.7), .clear, .black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(mediaAccessibilityLabel)
    }

    private var mediaAccessibilityLabel: String {
        switch viewData.mediaType {
        case .video, .ad:
            return accessibilityText.videoLabel(isMuted: isMuted)
        case .image, .poll:
            return accessibilityText.imageLabel(description: nil)
        }
    }
}

// MARK: - Timer Logic
private extension TimelineDetailAssetCard {

    func handleSelectionChange(_ selected: Bool) {
        if selected {
            startTimerIfNeeded()
        } else {
            stopTimer()
            hasValidVideo = false
        }
    }

    func startTimerIfNeeded() {
        // Start timer only for image and poll content
        // Video and ad types rely on video playback for progress
        guard viewData.mediaType == .image || viewData.mediaType == .poll else { return }

        stopTimer()
        progress = 0

        let updateInterval: TimeInterval = 0.05
        let progressIncrement = updateInterval / displayDuration

        timerTask = Task {
            while !Task.isCancelled && progress < 1.0 {
                try? await Task.sleep(nanoseconds: UInt64(updateInterval * 1_000_000_000))
                if !Task.isCancelled {
                    await MainActor.run {
                        progress = min(progress + progressIncrement, 1.0)
                    }
                }
            }
        }
    }

    func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
        progress = 0
    }
}

// MARK: - Overlay
private extension TimelineDetailAssetCard {

    var overlay: some View {
        VStack {
            // Top: Timestamp
            if viewData.showTimestamp {
                timestampLabel
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, sizeConfig.timestampTopMargin + sponsorLayout.topSponsorInset)
                    .padding(.horizontal, sizeConfig.timestampHorizontalMargin)
            }

            Spacer()

            // Bottom: Info section with action buttons
            HStack(alignment: .bottom, spacing: 4) {
                DetailBottomInfoSection(
                    viewData: viewData,
                    sizeConfig: sizeConfig,
                    onCtaButtonTap: onCtaButtonTap
                )

                actionButtons
                    .padding(.trailing, sizeConfig.contentHorizontalPadding)
                    .padding(.bottom, sizeConfig.bottomInfoPaddingBottom)
            }
            .padding(.bottom, sponsorLayout.bannerBottomInset)
        }
    }

    var actionButtons: some View {
        DetailActionButtonsView(
            isLiked: isLiked,
            mediaType: viewData.mediaType,
            shareContent: shareContent,
            sizeConfig: sizeConfig,
            isMuted: $isMuted,
            onLikeTap: onLikeTap,
            onShareTap: onShareTap
        )
    }

    var timestampLabel: some View {
        TimelineTimestampLabel(text: viewData.formattedTimestamp, style: sizeConfig)
    }

    /// Content to share - URL if available, otherwise text
    var shareContent: ShareableContent {
        if let url = viewData.ctaButton?.url ?? viewData.products.first?.ctaButton?.url {
            return .url(url)
        }
        var text = viewData.title
        if let subtitle = viewData.subtitle, !subtitle.isEmpty {
            text += "\n\n\(subtitle)"
        }
        return .text(text)
    }
}

// MARK: - Sponsor Actions
private extension TimelineDetailAssetCard {

    func handleSponsorTap(placement: AssetSponsorshipPlacement, position: SponsorshipPosition?, clickPosition: SponsorshipClickPosition, url: URL?) {
        onSponsorshipTap?(placement, position, clickPosition, url?.absoluteString)
        if let url { openURL(url) }
    }
}

// MARK: - Preview
#Preview {
    TimelineDetailAssetCard(
        viewData: TimelineAssetData(
            id: "1",
            mediaType: .video,
            imageURL: URL(string: "https://picsum.photos/800/600?random=1"),
            videoURL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"),
            timestamp: Date(),
            title: "Video test 1",
            subtitle: "Testing video. Testing video. Testing video. Testing video. Testing video. Testing video. Testing video. Testing video. Testing video.",
            brandLogoURL: "https://picsum.photos/100/100?random=2",
            ctaButton: CTAButtonData(
                text: "go to",
                url: URL(string: "https://example.com"),
                backgroundColor: .blue,
                textColor: .white
            ),
            products: [
                ProductData(from: .sampleFull),
                ProductData(from: .sampleNoBadge),
                ProductData(from: .sampleLightBackground)
            ]
        ),
        onCtaButtonTap: {
            print("CTA tapped!")
        },
        onProductCtaTap: { _, url  in
            print("Product CTA: \(url?.absoluteString ?? "nil")")
        },
        onLikeTap: {
            print("Like tapped!")
        },
        onShareTap: {
            print("Share tapped!")
        }
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .ignoresSafeArea()
    .background(Color.black)
}
