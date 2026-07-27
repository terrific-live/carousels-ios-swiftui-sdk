//
//  View+FloatingCloseButton.swift
//  CarouselDemo
//
//  Created by YuriyFpc on 21.01.2026.
//

import SwiftUI

public extension View {
    func floatingCloseButton(
        _ closeButtonTopPadding: CGFloat = 0,
        closeAction: @escaping () -> Void
    ) -> some View {
        self.modifier(
            CloseButtonOverContentModifier(
                closeButtonTopPadding: closeButtonTopPadding,
                closeAction: closeAction
            )
        )
    }
}

private struct CloseButtonOverContentModifier: ViewModifier {

    // MARK: - Environment
    @Environment(\.accessibilityText) private var accessibilityText

    // MARK: - Inputs
    private let closeButtonTopPadding: CGFloat
    private let closeAction: () -> Void

    // MARK: - Init
    init(
        closeButtonTopPadding: CGFloat = 0,
        closeAction: @escaping () -> Void
    ) {
        self.closeButtonTopPadding = closeButtonTopPadding
        self.closeAction = closeAction
    }

    // MARK: - Body
    func body(content: Content) -> some View {
        ZStack {
            content

            closeButtonContainer
        }
    }
}

// MARK: - UI Components
private extension CloseButtonOverContentModifier {
    var closeButtonContainer: some View {
        VStack {
            HStack {
                Spacer()
                closeButton
            }
            Spacer()
        }
    }

    var closeButton: some View {
        Button(action: {
            closeAction()
        }) {
            Circle()
                .fill(Color(white: 0.2))
                .overlay(
                    Circle()
                        .stroke(Color(white: 0.85), lineWidth: 1.5)
                )
                .overlay(
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(white: 0.85))
                )
                .frame(width: 32, height: 32)
                .accessibilityHidden(true)
        }
        .font(.system(size: 32, weight: .regular))
        .frame(width: 44, height: 44)
        .contentShape(.circle)
        .padding(.horizontal, 28)
        .padding(.top, closeButtonTopPadding)
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityText.closeButtonLabel)
        .accessibilityHint(accessibilityText.closeButtonHint)
    }
}
