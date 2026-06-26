//
//  DetailActionButtonsView.swift
//  TerrificCarouselSDK
//

import SwiftUI

struct DetailActionButtonsView: View {

    // MARK: - Environment
    @Environment(\.accessibilityText) private var accessibilityText

    // MARK: - Inputs
    let isLiked: Bool
    let mediaType: AssetMediaType
    let shareContent: ShareableContent
    let sizeConfig: DetailStyleConfiguration
    @Binding var isMuted: Bool
    let onLikeTap: (() -> Void)?
    let onShareTap: (() -> Void)?

    // MARK: - Body
    var body: some View {
        VStack(spacing: sizeConfig.actionButtonSpacing) {
            Button(action: {
                onLikeTap?()
            }) {
                Image(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                    .font(.system(size: sizeConfig.actionButtonIconSize))
                    .foregroundColor(.white)
            }
            .frame(width: 24, height: 24)
            .accessibilityLabel(isLiked ? accessibilityText.unlikeButtonLabel : accessibilityText.likeButtonLabel)

            shareButton
                .frame(width: 24, height: 24)
                .accessibilityLabel(accessibilityText.shareButtonLabel)

            // Sound on/off button (only for videos)
            if mediaType == .video {
                Button(action: {
                    isMuted.toggle()
                }) {
                    Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                        .font(.system(size: sizeConfig.actionButtonIconSize))
                        .foregroundColor(.white)
                }
                .frame(width: 24, height: 24)
                .accessibilityLabel(isMuted ? accessibilityText.unmuteButtonLabel : accessibilityText.muteButtonLabel)
            }
        }
    }

    // MARK: - Share Button
    @ViewBuilder
    private var shareButton: some View {
        if #available(iOS 16.0, *) {
            ShareButton(content: shareContent, onShare: onShareTap)
        } else {
            Button(action: {
                onShareTap?()
            }) {
                Image(systemName: "arrowshape.turn.up.right")
                    .font(.system(size: sizeConfig.actionButtonIconSize))
                    .foregroundColor(.white)
            }
        }
    }
}
