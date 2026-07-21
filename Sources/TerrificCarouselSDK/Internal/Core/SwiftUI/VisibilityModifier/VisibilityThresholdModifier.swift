//
//  VisibilityThresholdModifier.swift
//  TerrificCarouselSDK
//

import SwiftUI

// MARK: - VisibilityThresholdModifier
/// A view modifier that detects when a view's visibility crosses a threshold.
/// Uses global coordinate space to calculate visible percentage on screen.
struct VisibilityThresholdModifier: ViewModifier {

    // MARK: - Configuration
    let threshold: CGFloat
    let onThresholdCrossed: () -> Void

    // MARK: - State
    @State private var hasTriggered = false

    // MARK: - Body
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    if #available(iOS 17, macOS 14, tvOS 17, *) {
                        Color.clear
                            .onAppear {
                                checkVisibility(geometry: geometry)
                            }
                            .onChange(of: geometry.frame(in: .global)) { _, _ in
                                checkVisibility(geometry: geometry)
                            }
                    } else {
                        // iOS16-COMPAT: Remove when minimum target is iOS 17
                        Color.clear
                            .onAppear {
                                checkVisibility(geometry: geometry)
                            }
                            .onChange(of: geometry.frame(in: .global)) { _ in
                                checkVisibility(geometry: geometry)
                            }
                    }
                }
            )
    }

    // MARK: - Visibility Calculation
    private func checkVisibility(geometry: GeometryProxy) {
        guard !hasTriggered else { return }

        let frame = geometry.frame(in: .global)
        let screenHeight = UIScreen.main.bounds.height

        // Calculate visible portion
        let visibleTop = max(frame.minY, 0)
        let visibleBottom = min(frame.maxY, screenHeight)
        let visibleHeight = max(0, visibleBottom - visibleTop)

        // Guard against zero height
        guard frame.height > 0 else { return }

        let visiblePercentage = visibleHeight / frame.height

        if visiblePercentage >= threshold {
            hasTriggered = true
            onThresholdCrossed()
        }
    }
}

// MARK: - View Extension
extension View {
    /// Triggers a callback when the view's visibility crosses the specified threshold.
    /// - Parameters:
    ///   - threshold: Visibility percentage (0.0 to 1.0) required to trigger. Default is 0.5 (50%).
    ///   - action: Callback executed once when threshold is crossed.
    func onVisibilityThreshold(
        _ threshold: CGFloat = 0.5,
        perform action: @escaping () -> Void
    ) -> some View {
        modifier(VisibilityThresholdModifier(
            threshold: threshold,
            onThresholdCrossed: action
        ))
    }
}
