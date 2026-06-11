//
//  TimelineDetailErrorView.swift
//  TerrificCarouselSDK
//

import SwiftUI
import UIKit

// MARK: - View
struct TimelineDetailErrorView: View {

    // MARK: - Callbacks
    let onRetry: () -> Void

    // MARK: - Body
    var body: some View {
        VStack(spacing: 12) {
            Spacer()

            errorImage
            titleText
            subtitleText
            retryButton

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            NSLocalizedString("accessibility.error.label", bundle: .module, comment: "")
        )
    }
}

// MARK: - UI Components
private extension TimelineDetailErrorView {

    @ViewBuilder
    var errorImage: some View {
        if let url = Bundle.module.url(forResource: "error_image", withExtension: "png"),
           let data = try? Data(contentsOf: url),
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 16)
                .accessibilityHidden(true)
        }
    }

    var titleText: some View {
        Text(NSLocalizedString("error.title", bundle: .module, comment: ""))
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.black)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
    }

    var subtitleText: some View {
        Text(NSLocalizedString("error.subtitle", bundle: .module, comment: ""))
            .font(.system(size: 17, weight: .regular))
            .foregroundColor(.black.opacity(0.7))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
    }

    var retryButton: some View {
        Button(action: onRetry) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 16, weight: .semibold))
                Text(NSLocalizedString("error.retry_button", bundle: .module, comment: ""))
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0.95, green: 0.55, blue: 0.25))
            )
        }
        .padding(.top, 8)
        .accessibilityHint(
            NSLocalizedString("accessibility.error.retry_hint", bundle: .module, comment: "")
        )
    }
}

// MARK: - Preview
#Preview {
    TimelineDetailErrorView {
        print("Retry tapped")
    }
}
