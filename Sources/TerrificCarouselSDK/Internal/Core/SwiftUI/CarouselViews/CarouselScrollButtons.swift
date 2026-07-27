//
//  CarouselScrollButtons.swift
//  TerrificCarouselSDK
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// Navigation buttons for horizontal carousel scrolling on iPad.
/// Displays left/right arrow buttons in a dark capsule container.
struct CarouselScrollButtons: View {

    enum HighlightedButton: Equatable {
        case previous
        case next
    }

    // MARK: - Environment
    @Environment(\.accessibilityText) private var accessibilityText

    // MARK: - Inputs
    let canScrollPrevious: Bool
    let canScrollNext: Bool
    @Binding var highlightedButton: HighlightedButton?
    let buttonSize: CGFloat
    let iconSize: CGFloat
    let buttonSpacing: CGFloat
    let capsuleHorizontalPadding: CGFloat
    let capsuleVerticalPadding: CGFloat
    let onScrollPrevious: () -> Void
    let onScrollNext: () -> Void

    // MARK: - Body
    var body: some View {
        HStack(spacing: buttonSpacing) {
            scrollButton(direction: .previous)
            scrollButton(direction: .next)
        }
        .padding(.horizontal, capsuleHorizontalPadding)
        .padding(.vertical, capsuleVerticalPadding)
        .background(
            Capsule()
                .fill(Color(white: 0.12))
        )
    }

    // MARK: - Button
    @ViewBuilder
    private func scrollButton(direction: HighlightedButton) -> some View {
        let isHighlighted = highlightedButton == direction
        let isEnabled = direction == .previous ? canScrollPrevious : canScrollNext
        let iconName = direction == .previous ? "arrow.left" : "arrow.right"
        let label = direction == .previous
            ? accessibilityText.scrollPreviousButtonLabel
            : accessibilityText.scrollNextButtonLabel
        let hint = direction == .previous
            ? accessibilityText.scrollPreviousButtonHint
            : accessibilityText.scrollNextButtonHint

        Button(action: {
            if direction == .previous {
                onScrollPrevious()
            } else {
                onScrollNext()
            }
            highlightedButton = direction
        }) {
            Circle()
                .fill(isHighlighted ? Color(white: 0.22) : Color.clear)
                .overlay(
                    Image(systemName: iconName)
                        .font(.system(size: iconSize, weight: .semibold))
                        .foregroundColor(Color(white: 0.7))
                )
                .frame(width: buttonSize, height: buttonSize)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.4)
        .accessibilityLabel(label)
        .accessibilityHint(hint)
    }
}
