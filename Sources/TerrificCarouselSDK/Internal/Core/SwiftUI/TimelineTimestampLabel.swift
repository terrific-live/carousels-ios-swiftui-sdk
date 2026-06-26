//
//  TimelineTimestampLabel.swift
//  TerrificCarouselSDK
//

import SwiftUI

// MARK: - TimestampStyleProviding
/// Shared protocol for timestamp label styling across Feed and Detail configurations.
protocol TimestampStyleProviding {
    var timestampFont: CarouselFontDescriptor { get }
    var timestampPaddingHorizontal: CGFloat { get }
    var timestampPaddingVertical: CGFloat { get }
    var timestampCornerRadius: CGFloat { get }
}

// MARK: - TimelineTimestampLabel
/// Reusable timestamp badge used in both Feed and Detail asset cards.
struct TimelineTimestampLabel<Style: TimestampStyleProviding>: View {

    let text: String
    let style: Style

    var body: some View {
        Text(text)
            .font(style.timestampFont.toFont())
            .foregroundColor(.black)
            .padding(.horizontal, style.timestampPaddingHorizontal)
            .padding(.vertical, style.timestampPaddingVertical)
            .background(
                RoundedRectangle(cornerRadius: style.timestampCornerRadius)
                    .fill(Color.white)
            )
    }
}
