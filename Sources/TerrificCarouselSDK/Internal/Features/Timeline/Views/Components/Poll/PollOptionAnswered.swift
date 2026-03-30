//
//  PollOptionAnswered.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 18.02.2026.
//

import SwiftUI

// MARK: - PollOptionAnswered
struct PollOptionAnswered: View {
    let text: String
    let percentage: Int
    let percentageFraction: Double
    let isSelected: Bool
    let sizeConfig: PollStyleConfiguration
    let isInteractive: Bool
    let onTap: () -> Void

    // MARK: - Highlight State
    @State private var showHighlight: Bool = false

    var body: some View {
        if isInteractive {
            Button(action: handleTap) {
                optionContent
            }
            .buttonStyle(.plain)
        } else {
            optionContent
        }
    }

    private func handleTap() {
        // Show highlight immediately
        withAnimation(.easeIn(duration: 0.1)) {
            showHighlight = true
        }

        // Call the tap handler
        onTap()

        // Remove highlight after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + PollOptionStyle.highlightDuration) {
            withAnimation(.easeOut(duration: 0.2)) {
                showHighlight = false
            }
        }
    }

    private var optionContent: some View {
        HStack {
            Text(text)
                .font(sizeConfig.optionFont.toFont())
                .foregroundColor(showHighlight ? PollOptionStyle.highlightColor : .black)
                .lineLimit(2)

            Spacer()

            Text("\(percentage)%")
                .font(sizeConfig.optionSelectedFont.toFont())
                .foregroundColor(showHighlight ? PollOptionStyle.highlightColor.opacity(0.7) : .black.opacity(0.7))
        }
        .padding(.horizontal, 16)
        .frame(height: sizeConfig.optionHeight)
        .background(
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)

                    // Progress fill
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.gray: Color.gray.opacity(0.3))
                        .frame(width: geometry.size.width * percentageFraction)
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .animation(.easeInOut(duration: 0.3), value: percentageFraction)
    }
}
