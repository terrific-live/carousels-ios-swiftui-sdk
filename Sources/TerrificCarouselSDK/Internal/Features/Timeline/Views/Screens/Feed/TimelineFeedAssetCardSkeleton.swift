//
//  TimelineFeedSkeletonCarousel.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 15.01.2026.
//

import SwiftUI

// MARK: - Carousel Skeleton (Multiple Cards)
struct TimelineFeedSkeletonCarousel: View {

    // MARK: - Environment
    @Environment(\.accessibilityText) private var accessibilityText

    // MARK: - Configuration
    let sizeConfig: FeedStyleConfiguration
    let showNameLabel: Bool
    private let cardCount: Int = 6

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
                        TimelineAssetCardSkeleton(mode: .feed(sizeConfig))
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText.loadingLabel)
    }
}

// MARK: - Previews
#Preview("Single Card") {
    TimelineAssetCardSkeleton(mode: .feed(.default))
        .frame(width: 300, height: 480)
        .padding()
}

#Preview("Carousel") {
    TimelineFeedSkeletonCarousel()
        .frame(height: 550)
}
