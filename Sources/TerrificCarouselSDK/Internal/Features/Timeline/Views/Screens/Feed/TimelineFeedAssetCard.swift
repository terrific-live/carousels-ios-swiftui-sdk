//
//  TimelineAssetCard.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 15.01.2026.
//

import SwiftUI
import ImageLoader
import MediaPlayback

struct TimelineFeedAssetCard: View {

    // MARK: - Inputs
    let viewData: TimelineAssetData
    let isSelected: Bool
    let sizeConfig: FeedSizeConfiguration
    let onProductCtaTap: ((URL?) -> Void)?

    // MARK: - Init
    init(
        viewData: TimelineAssetData,
        isSelected: Bool = false,
        sizeConfig: FeedSizeConfiguration = .default,
        onProductCtaTap: ((URL?) -> Void)? = nil
    ) {
        self.viewData = viewData
        self.isSelected = isSelected
        self.sizeConfig = sizeConfig
        self.onProductCtaTap = onProductCtaTap
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: sizeConfig.cardSpacing) {
            // Asset Card
            assetCard

            // Products Carousel (feed mode - no price, no CTA)
            if !viewData.products.isEmpty {
                ProductCarouselView(
                    products: viewData.products,
                    displayMode: .compact,
                    isSelected: isSelected,
                    onCtaTap: onProductCtaTap
                )
            }
        }
    }

    // MARK: - Asset Card
    private var assetCard: some View {
        ZStack {
            // Content based on media type
            switch viewData.mediaType {
            case .poll:
                pollContent
            case .image, .video, .ad:
                mediaContent
            }

            // Overlay (timestamp for poll, full overlay for media)
            if viewData.mediaType == .poll {
                pollOverlay
            } else {
                overlay
            }
        }
        .background(
            viewData.mediaType == .poll
                ? AnyShapeStyle(LinearGradient(
                    colors: [viewData.primaryBackgroundColor, viewData.secondaryBackgroundColor],
                    startPoint: .top,
                    endPoint: .bottom
                ))
                : AnyShapeStyle(Color(.systemBackground))
        )
        .clipShape(RoundedRectangle(cornerRadius: sizeConfig.cardCornerRadius))
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .clipped()
        .onChange(of: isSelected) { oldValue, newValue in
            print("📱 [TimelineAssetCard] Asset '\(viewData.title)' (mediaType=\(viewData.mediaType)) isSelected: \(oldValue) -> \(newValue)")
        }
    }

    // MARK: - Poll Content
    @ViewBuilder
    private var pollContent: some View {
        if let pollViewModel = viewData.pollViewModel {
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    PollView(
                        viewModel: pollViewModel,
                        sizeConfig: sizeConfig.poll,
                        displayMode: .readOnly  // Shows actual state, but no interaction allowed
                    )
                    Spacer()
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }

    // MARK: - Poll Overlay
    private var pollOverlay: some View {
        VStack {
            if viewData.showTimestamp {
                timestampLabel
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, sizeConfig.timestampTopMargin)
                    .padding(.horizontal, sizeConfig.timestampHorizontalMargin)
            }

            Spacer()
        }
    }

    // MARK: - Media Content
    @ViewBuilder
    private var mediaContent: some View {
        MediaContentView(
            videoURL: viewData.videoPreviewURLForFeed,
            configuration: VideoPreviewConfiguration.timelineCard,
            isSelected: isSelected,
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
    }
}

// MARK: - Overlay
extension TimelineFeedAssetCard {
    @ViewBuilder
    private var overlay: some View {
        VStack {
            if viewData.showTimestamp {
                timestampLabel
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, sizeConfig.timestampTopMargin)
                    .padding(.horizontal, sizeConfig.timestampHorizontalMargin)
            }

            Spacer()

            bottomInfo
        }
    }

    private var timestampLabel: some View {
        Text(viewData.formattedTimestamp)
            .font(sizeConfig.timestampFont.toFont())
            .foregroundColor(.black)
            .padding(.horizontal, sizeConfig.timestampPaddingHorizontal)
            .padding(.vertical, sizeConfig.timestampPaddingVertical)
            .background(
                RoundedRectangle(cornerRadius: sizeConfig.timestampCornerRadius)
                    .fill(Color.white)
            )
    }

    private var bottomInfo: some View {
        VStack(alignment: .leading, spacing: sizeConfig.titleSubtitleSpacing) {
            // Title
            Text(viewData.title)
                .font(sizeConfig.titleFont.toFont())
                .foregroundColor(.white)
                .lineLimit(1)

            // Subtitle
            if let subtitle = viewData.subtitle {
                Text(subtitle)
                    .font(sizeConfig.subtitleFont.toFont())
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, sizeConfig.bottomInfoPaddingHorizontal)
        .padding(.bottom, sizeConfig.bottomInfoPaddingBottom)
        .padding(.top, 8)
        .background(
            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - Preview
#Preview {
    TimelineFeedAssetCard(
        viewData: TimelineAssetData(
            id: "1",
            mediaType: .video,
            imageURL: URL(string: "https://picsum.photos/800/600?random=1"),
            videoURL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"),
            timestamp: Date(),
            title: "Video test 1",
            subtitle: "Testing video. Testing video. Testing video...",
            products: [
                ProductData(from: .sampleFull),
                ProductData(from: .sampleNoBadge)
            ]
        ),
        onProductCtaTap: { url in
            print("Product CTA: \(url?.absoluteString ?? "nil")")
        }
    )
    .frame(width: 300, height: 480)
    .padding()
}
