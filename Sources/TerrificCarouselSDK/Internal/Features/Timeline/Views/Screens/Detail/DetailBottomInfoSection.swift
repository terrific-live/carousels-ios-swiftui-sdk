//
//  DetailBottomInfoSection.swift
//  TerrificCarouselSDK
//

import SwiftUI
import ImageLoader

struct DetailBottomInfoSection: View {

    // MARK: - Environment
    @Environment(\.accessibilityText) private var accessibilityText

    // MARK: - Constants
    private let collapsedLineLimit = 6
    private let expandedLineLimit = 12

    // MARK: - Inputs
    let viewData: TimelineAssetData
    let sizeConfig: DetailStyleConfiguration
    let onCtaButtonTap: (() -> Void)?

    // MARK: - State
    @State private var isSubtitleExpanded = false
    @State private var isSubtitleTruncated = false

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: sizeConfig.contentSpacing) {
            // Brand logo
            if let brandLogoURL = viewData.brandLogoURL {
                CachedAsyncImage(urlString: brandLogoURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: sizeConfig.brandLogoSize, height: sizeConfig.brandLogoSize)
                        .clipShape(RoundedRectangle(cornerRadius: sizeConfig.brandLogoCornerRadius))
                } placeholder: {
                    RoundedRectangle(cornerRadius: sizeConfig.brandLogoCornerRadius)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: sizeConfig.brandLogoSize, height: sizeConfig.brandLogoSize)
                }
            }

            // Title
            Text(viewData.title)
                .font(sizeConfig.titleFont.toFont())
                .foregroundColor(.white)

            // Subtitle with truncation detection
            if let subtitle = viewData.subtitle {
                TruncatableText(
                    text: subtitle,
                    font: sizeConfig.subtitleFont.toFont(),
                    lineLimit: isSubtitleExpanded ? expandedLineLimit : collapsedLineLimit,
                    isTruncated: $isSubtitleTruncated
                )
                .foregroundColor(.white.opacity(0.85))
                .animation(.easeInOut(duration: 0.3), value: isSubtitleExpanded)
            }

            // Read more / Read less button (only visible when text is truncated)
            if isSubtitleTruncated || isSubtitleExpanded {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isSubtitleExpanded.toggle()
                    }
                }) {
                    Text(isSubtitleExpanded ? "Read less" : "Read more")
                        .font(sizeConfig.subtitleFont.toFont())
                        .foregroundColor(.white)
                }
                .accessibilityLabel(isSubtitleExpanded ? accessibilityText.readLessButtonLabel : accessibilityText.readMoreButtonLabel)
            }

            // CTA Button
            if let ctaButton = viewData.ctaButton {
                Button(action: {
                    onCtaButtonTap?()
                }) {
                    Text(ctaButton.text)
                        .font(sizeConfig.ctaButtonFont.toFont())
                        .foregroundColor(ctaButton.textColor)
                        .padding(.horizontal, sizeConfig.ctaButtonPaddingHorizontal)
                        .padding(.vertical, sizeConfig.ctaButtonPaddingVertical)
                        .background(
                            Capsule()
                                .fill(ctaButton.backgroundColor)
                        )
                }
                .padding(.top, 4)
                .accessibilityLabel(accessibilityText.ctaButtonLabel(title: ctaButton.text))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, sizeConfig.contentHorizontalPadding)
        .padding(.bottom, sizeConfig.bottomInfoPaddingBottom)
        .padding(.top, sizeConfig.bottomInfoPaddingBottom)
    }
}
