//
//  TimelineDetailAssetCardSkeleton.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 25.02.2026.
//

import SwiftUI

// MARK: - TimelineDetailAssetCardSkeleton
struct TimelineDetailAssetCardSkeleton: View {

    // MARK: - Constants
    private let edgePadding: CGFloat = 16

    // MARK: - Animation State
    @State private var shimmerOffset: CGFloat = -500

    // MARK: - Body
    var body: some View {
        VStack(spacing: 8) {
            // Asset Card Skeleton
            assetCardSkeleton
        }
        .padding(edgePadding)
        .background(
            LinearGradient(
                colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
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
            // Background placeholder
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.3))
                .shimmer(offset: shimmerOffset)

            // Overlay content
            VStack {
                // Top: Timestamp
                timestampSkeleton
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                    .padding(.horizontal, 16)

                Spacer()

                // Bottom: Info section with action buttons
                HStack(alignment: .bottom, spacing: 4) {
                    bottomInfoSkeleton

                    actionButtonsSkeleton
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Timestamp Skeleton
    private var timestampSkeleton: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.white.opacity(0.3))
            .frame(width: 120, height: 32)
            .shimmer(offset: shimmerOffset)
    }

    // MARK: - Action Buttons Skeleton
    private var actionButtonsSkeleton: some View {
        VStack(spacing: 24) {
            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 40, height: 40)
                .shimmer(offset: shimmerOffset)

            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 40, height: 40)
                .shimmer(offset: shimmerOffset)
        }
        .padding(.trailing, 16)
        .padding(.bottom, 16)
    }

    // MARK: - Bottom Info Skeleton
    private var bottomInfoSkeleton: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Brand logo skeleton
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.2))
                .frame(width: 60, height: 60)
                .shimmer(offset: shimmerOffset)

            // Title skeleton
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white.opacity(0.3))
                .frame(width: 200, height: 24)
                .shimmer(offset: shimmerOffset)

            // Subtitle skeleton lines
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.2))
                    .frame(maxWidth: .infinity)
                    .frame(height: 18)
                    .shimmer(offset: shimmerOffset)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 250, height: 18)
                    .shimmer(offset: shimmerOffset)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 180, height: 18)
                    .shimmer(offset: shimmerOffset)
            }

            // CTA Button skeleton
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.2))
                .frame(width: 140, height: 44)
                .shimmer(offset: shimmerOffset)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .padding(.top, 16)
    }
}

// MARK: - Shimmer Extension
private extension View {
    func shimmer(offset: CGFloat) -> some View {
        self
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color.white.opacity(0.3),
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

// MARK: - Preview
#Preview {
    TimelineDetailAssetCardSkeleton()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .ignoresSafeArea()
}
