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
            Image(systemName: "xmark.circle")
                .accessibilityHidden(true)
        }
        .font(.system(size: 32, weight: .regular))
        .foregroundStyle(Color(white: 0.75))
        .frame(width: 44, height: 44)
        .contentShape(.circle)
        .padding(.horizontal, closeButtonTopPadding)
        .padding(.top, closeButtonTopPadding)
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
    }
}

// MARK: - Strings & Accessibility
private extension CloseButtonOverContentModifier {
    var accessibilityLabel: LocalizedStringKey {
        LocalizedStringKey("Close screen")
    }

    var accessibilityHint: LocalizedStringKey {
        LocalizedStringKey("Dismiss this screen and return to the previous view")
    }
}
