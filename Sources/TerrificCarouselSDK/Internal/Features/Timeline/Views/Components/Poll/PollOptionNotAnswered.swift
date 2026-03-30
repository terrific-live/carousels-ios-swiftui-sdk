//
//  PollOptionNotAnswered.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 18.02.2026.
//

import SwiftUI

// MARK: - PollOptionNotAnswered
struct PollOptionNotAnswered: View {
    let text: String
    let sizeConfig: PollSizeConfiguration
    let isInteractive: Bool
    let isSelected: Bool
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
        }
        .padding(.horizontal, 16)
        .frame(height: sizeConfig.optionHeight)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
    }
}
