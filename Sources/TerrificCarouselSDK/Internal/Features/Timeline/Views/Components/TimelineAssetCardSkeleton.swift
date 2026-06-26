//
//  TimelineAssetCardSkeleton.swift
//  TerrificCarouselSDK
//

import SwiftUI

// MARK: - TimelineAssetCardSkeleton
/// Unified skeleton loading placeholder for both Feed and Detail asset cards.
/// Use `.feed(config)` for horizontal carousel items, `.detail` for fullscreen items.
struct TimelineAssetCardSkeleton: View {

    // MARK: - Mode
    enum Mode {
        case feed(FeedStyleConfiguration)
        case detail
    }

    // MARK: - Environment
    @Environment(\.accessibilityText) private var accessibilityText

    // MARK: - Properties
    let mode: Mode
    @State private var shimmerOffset: CGFloat = -500

    // MARK: - Body
    var body: some View {
        cardWrapper
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

// MARK: - Card Wrapper
private extension TimelineAssetCardSkeleton {

    @ViewBuilder
    var cardWrapper: some View {
        switch mode {
        case .feed(let config):
            VStack(spacing: config.cardSpacing) {
                feedCardSkeleton(config)
            }
        case .detail:
            VStack(spacing: 8) {
                detailCardSkeleton
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
}

// MARK: - Feed Card
private extension TimelineAssetCardSkeleton {

    func feedCardSkeleton(_ config: FeedStyleConfiguration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: config.cardCornerRadius)
                .fill(Color.gray.opacity(0.15))
                .shimmer(offset: shimmerOffset)

            VStack {
                // Timestamp
                RoundedRectangle(cornerRadius: config.timestampCornerRadius)
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 70, height: 28)
                    .shimmer(offset: shimmerOffset)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, config.timestampTopMargin)
                    .padding(.horizontal, config.timestampHorizontalMargin)

                Spacer()

                // Bottom info
                VStack(alignment: .leading, spacing: config.titleSubtitleSpacing) {
                    // Title
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.7))
                        .frame(height: 20)
                        .frame(maxWidth: 180)
                        .shimmer(offset: shimmerOffset)

                    // Subtitle
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.5))
                        .frame(height: 16)
                        .frame(maxWidth: 220)
                        .shimmer(offset: shimmerOffset)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, config.bottomInfoPaddingHorizontal)
                .padding(.bottom, config.bottomInfoPaddingBottom)
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
        .clipShape(RoundedRectangle(cornerRadius: config.cardCornerRadius))
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Detail Card
private extension TimelineAssetCardSkeleton {

    var detailCardSkeleton: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.3))
                .shimmer(offset: shimmerOffset, opacity: 0.3)

            VStack {
                // Timestamp
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 120, height: 32)
                    .shimmer(offset: shimmerOffset, opacity: 0.3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                    .padding(.horizontal, 16)

                Spacer()

                // Bottom: Info + Action buttons
                HStack(alignment: .bottom, spacing: 4) {
                    detailBottomInfoSkeleton
                    detailActionButtonsSkeleton
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    var detailActionButtonsSkeleton: some View {
        VStack(spacing: 24) {
            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 40, height: 40)
                .shimmer(offset: shimmerOffset, opacity: 0.3)

            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 40, height: 40)
                .shimmer(offset: shimmerOffset, opacity: 0.3)
        }
        .padding(.trailing, 16)
        .padding(.bottom, 16)
    }

    var detailBottomInfoSkeleton: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Brand logo
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.2))
                .frame(width: 60, height: 60)
                .shimmer(offset: shimmerOffset, opacity: 0.3)

            // Title
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white.opacity(0.3))
                .frame(width: 200, height: 24)
                .shimmer(offset: shimmerOffset, opacity: 0.3)

            // Subtitle lines
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.2))
                    .frame(maxWidth: .infinity)
                    .frame(height: 18)
                    .shimmer(offset: shimmerOffset, opacity: 0.3)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 250, height: 18)
                    .shimmer(offset: shimmerOffset, opacity: 0.3)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 180, height: 18)
                    .shimmer(offset: shimmerOffset, opacity: 0.3)
            }

            // CTA Button
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.2))
                .frame(width: 140, height: 44)
                .shimmer(offset: shimmerOffset, opacity: 0.3)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .padding(.top, 16)
    }
}

// MARK: - Previews
#Preview("Feed Card") {
    TimelineAssetCardSkeleton(mode: .feed(.default))
        .frame(width: 300, height: 480)
        .padding()
}

#Preview("Detail Card") {
    TimelineAssetCardSkeleton(mode: .detail)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .ignoresSafeArea()
}
