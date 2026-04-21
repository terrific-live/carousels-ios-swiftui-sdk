//
//  SwipeHintOverlayView.swift
//  TerrificCarouselSDK
//

import SwiftUI

/// Overlay view that shows an animated swipe-up hint to guide users
/// Animation: chevrons move up from bottom one by one → hold → disappear
struct SwipeHintOverlayView: View {

    // MARK: - Configuration
    private let chevronSize: CGFloat = 36
    private let chevronSpacing: CGFloat = -8
    private let moveDistance: CGFloat = 60
    private let animationStepDuration: Double = 0.35
    private let holdDuration: Double = 0.5

    // MARK: - Inputs
    let text: String?
    let onDismiss: () -> Void

    // MARK: - State
    @State private var firstChevronOffset: CGFloat = 60
    @State private var secondChevronOffset: CGFloat = 60
    @State private var thirdChevronOffset: CGFloat = 60
    @State private var firstChevronOpacity: Double = 0
    @State private var secondChevronOpacity: Double = 0
    @State private var thirdChevronOpacity: Double = 0
    @State private var fadeOut = false

    // MARK: - Body
    var body: some View {
        ZStack {
            // Dark background
            Color.black
                .opacity(fadeOut ? 0 : 0.5)

            // Chevrons and text
            VStack(spacing: 44) {
                chevronsStack

                Text(text ?? "Swipe")
                    .font(.system(size: 28, weight: .medium))
                    .shadow(color: .black, radius: 1, x: 1, y: 1)
                    .foregroundColor(.white)
                    .opacity(fadeOut ? 0 : 1)
            }
        }
        .ignoresSafeArea()
        .onTapGesture {
            dismissWithAnimation()
        }
        .onAppear {
            startAnimation()
        }
    }

    // MARK: - Chevrons Stack
    private var chevronsStack: some View {
        VStack(spacing: chevronSpacing) {
            // First chevron (top) - arrives first
            chevronImage
                .opacity(firstChevronOpacity)
                .offset(y: firstChevronOffset)

            // Second chevron (middle) - arrives second
            chevronImage
                .opacity(secondChevronOpacity)
                .offset(y: secondChevronOffset)

            // Third chevron (bottom) - arrives last
            chevronImage
                .opacity(thirdChevronOpacity)
                .offset(y: thirdChevronOffset)
        }
    }

    private var chevronImage: some View {
        Image(systemName: "chevron.up")
            .font(.system(size: chevronSize, weight: .medium))
            .foregroundColor(.white)
    }

    // MARK: - Animation Sequence
    private func startAnimation() {
        // Step 1: First chevron moves up from bottom
        withAnimation(.easeOut(duration: animationStepDuration)) {
            firstChevronOffset = 0
            firstChevronOpacity = 1
        }

        // Step 2: Second chevron moves up from bottom
        DispatchQueue.main.asyncAfter(deadline: .now() + animationStepDuration * 0.6) {
            withAnimation(.easeOut(duration: animationStepDuration)) {
                secondChevronOffset = 0
                secondChevronOpacity = 1
            }
        }

        // Step 3: Third chevron moves up from bottom
        DispatchQueue.main.asyncAfter(deadline: .now() + animationStepDuration * 1.2) {
            withAnimation(.easeOut(duration: animationStepDuration)) {
                thirdChevronOffset = 0
                thirdChevronOpacity = 1
            }
        }

        // Step 4: Hold, then fade out and dismiss
        let totalAnimationTime = animationStepDuration * 1.2 + animationStepDuration + holdDuration
        DispatchQueue.main.asyncAfter(deadline: .now() + totalAnimationTime) {
            dismissWithAnimation()
        }
    }

    private func dismissWithAnimation() {
        withAnimation(.easeOut(duration: 0.3)) {
            fadeOut = true
            firstChevronOpacity = 0
            secondChevronOpacity = 0
            thirdChevronOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        // Sample background content
        Color.gray

        SwipeHintOverlayView(text: "Défilez") {
            print("Dismissed")
        }
    }
}
