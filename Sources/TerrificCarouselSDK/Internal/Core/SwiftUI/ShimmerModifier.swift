//
//  ShimmerModifier.swift
//  TerrificCarouselSDK
//

import SwiftUI

// MARK: - Shimmer View Extension
extension View {
    /// Applies a shimmer loading animation overlay.
    /// - Parameters:
    ///   - offset: The horizontal offset driving the shimmer position (animate from -500 to 500).
    ///   - opacity: The peak opacity of the shimmer highlight. Defaults to 0.4.
    func shimmer(offset: CGFloat, opacity: Double = 0.4) -> some View {
        self
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color.white.opacity(opacity),
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
