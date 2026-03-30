//
//  ShareSheet16+.swift
//  CarouselDemo
//

import SwiftUI

// MARK: - ShareableContent
/// Represents content that can be shared via ShareLink
enum ShareableContent {
    case url(URL)
    case text(String)
}

// MARK: - ShareButton (iOS 16+)
/// A native SwiftUI share button using ShareLink
@available(iOS 16.0, *)
struct ShareButton<Label: View>: View {
    let content: ShareableContent
    let onShare: (() -> Void)?
    let label: () -> Label

    init(
        content: ShareableContent,
        onShare: (() -> Void)? = nil,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.content = content
        self.onShare = onShare
        self.label = label
    }

    var body: some View {
        Group {
            switch content {
            case .url(let url):
                ShareLink(item: url) {
                    label()
                }
            case .text(let text):
                ShareLink(item: text) {
                    label()
                }
            }
        }
        .simultaneousGesture(TapGesture().onEnded { _ in
            onShare?()
        })
    }
}

// MARK: - Convenience initializer with default label
@available(iOS 16.0, *)
extension ShareButton where Label == ShareButtonDefaultLabel {
    init(
        content: ShareableContent,
        onShare: (() -> Void)? = nil
    ) {
        self.content = content
        self.onShare = onShare
        self.label = { ShareButtonDefaultLabel() }
    }
}

// MARK: - Default Share Button Label
struct ShareButtonDefaultLabel: View {
    var body: some View {
        Image(systemName: "arrowshape.turn.up.right")
            .font(.system(size: 24))
            .foregroundColor(.white)
            .frame(width: 32, height: 32)
    }
}
