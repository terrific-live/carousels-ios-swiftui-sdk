//
//  TimelineAssetCardSkeleton.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 15.01.2026.
//

import SwiftUI

// MARK: - Single Skeleton Card
struct TimelineFeedAssetCardSkeleton: View {

    // MARK: - Configuration
    let sizeConfig: FeedStyleConfiguration

    // MARK: - State
    @State private var shimmerOffset: CGFloat = -500

    // MARK: - Init
    init(sizeConfig: FeedStyleConfiguration = .default) {
        self.sizeConfig = sizeConfig
    }

    var body: some View {
        VStack(spacing: sizeConfig.cardSpacing) {
            // Main asset card skeleton
            assetCardSkeleton
        }
        .onAppear {
            withAnimation(
                Animation.linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
            ) {
                shimmerOffset = 500
            }
        }
    }

    // MARK: - Asset Card Skeleton
    private var assetCardSkeleton: some View {
        ZStack {
            // Background placeholder for media
            RoundedRectangle(cornerRadius: sizeConfig.cardCornerRadius)
                .fill(Color.gray.opacity(0.15))
                .shimmer(offset: shimmerOffset)

            // Overlay structure matching real card
            VStack {
                // Timestamp badge at top-left
                timestampSkeleton
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, sizeConfig.timestampTopMargin)
                    .padding(.horizontal, sizeConfig.timestampHorizontalMargin)

                Spacer()

                // Bottom info overlay
                bottomInfoSkeleton
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: sizeConfig.cardCornerRadius))
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    private var timestampSkeleton: some View {
        RoundedRectangle(cornerRadius: sizeConfig.timestampCornerRadius)
            .fill(Color.white.opacity(0.9))
            .frame(width: 70, height: 28)
            .shimmer(offset: shimmerOffset)
    }

    private var bottomInfoSkeleton: some View {
        VStack(alignment: .leading, spacing: sizeConfig.titleSubtitleSpacing) {
            // Title skeleton
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white.opacity(0.7))
                .frame(height: 20)
                .frame(maxWidth: 180)
                .shimmer(offset: shimmerOffset)

            // Subtitle skeleton
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white.opacity(0.5))
                .frame(height: 16)
                .frame(maxWidth: 220)
                .shimmer(offset: shimmerOffset)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, sizeConfig.bottomInfoPaddingHorizontal)
        .padding(.bottom, sizeConfig.bottomInfoPaddingBottom)
        .padding(.top, 8)
        .background(
            LinearGradient(
                colors: [.clear, .black.opacity(0.5)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - Carousel Skeleton (Multiple Cards)
struct TimelineFeedSkeletonCarousel: View {

    // MARK: - Configuration
    let sizeConfig: FeedStyleConfiguration
    let showNameLabel: Bool
    private let cardCount: Int = 3

    // MARK: - State
    @State private var shimmerOffset: CGFloat = -500

    // MARK: - Init
    init(sizeConfig: FeedStyleConfiguration = .default, showNameLabel: Bool = true) {
        self.sizeConfig = sizeConfig
        self.showNameLabel = showNameLabel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Carousel name label skeleton
            if showNameLabel {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 200, height: sizeConfig.carouselNameFont.size)
                    .shimmer(offset: shimmerOffset)
                    .padding(.horizontal, sizeConfig.carouselNameHorizontalPadding)
                    .padding(.bottom, sizeConfig.carouselNameBottomPadding)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: sizeConfig.carouselItemSpacing) {
                    ForEach(0..<cardCount, id: \.self) { _ in
                        TimelineFeedAssetCardSkeleton(sizeConfig: sizeConfig)
                            .frame(width: sizeConfig.carouselItemWidth, height: sizeConfig.carouselItemHeight)
                    }
                }
                .padding(.horizontal, sizeConfig.carouselHorizontalPadding)
            }
            .scrollDisabled(true)
        }
        .onAppear {
            withAnimation(
                Animation.linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
            ) {
                shimmerOffset = 500
            }
        }
    }
}

private extension View {
    func shimmer(offset: CGFloat) -> some View {
        self
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color.white.opacity(0.4),
                                Color.clear
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .rotationEffect(.degrees(30))
                    .offset(x: offset)
            )
            .clipped()
    }
}

// MARK: - Previews
#Preview("Single Card") {
    TimelineFeedAssetCardSkeleton()
        .frame(width: 300, height: 480)
        .padding()
}

#Preview("Carousel") {
    TimelineFeedSkeletonCarousel()
        .frame(height: 550)
}
