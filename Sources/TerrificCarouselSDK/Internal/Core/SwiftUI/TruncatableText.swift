//
//  TruncatableText.swift
//  TerrificCarouselSDK
//

import SwiftUI

/// A text view that detects whether its content is being truncated
struct TruncatableText: View {
    let text: String
    let font: Font
    let lineLimit: Int
    @Binding var isTruncated: Bool

    var body: some View {
        Text(text)
            .font(font)
            .lineLimit(lineLimit)
            .background(
                // Hidden text to measure full height
                Text(text)
                    .font(font)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .hidden()
                    .background(
                        GeometryReader { fullTextGeometry in
                            // Visible text to measure truncated height
                            Text(text)
                                .font(font)
                                .lineLimit(lineLimit)
                                .background(
                                    GeometryReader { truncatedGeometry in
                                        if #available(iOS 17, macOS 14, tvOS 17, *) {
                                            Color.clear.onAppear {
                                                checkTruncation(fullHeight: fullTextGeometry.size.height, truncatedHeight: truncatedGeometry.size.height)
                                            }
                                            .onChange(of: lineLimit) { _, _ in
                                                checkTruncation(fullHeight: fullTextGeometry.size.height, truncatedHeight: truncatedGeometry.size.height)
                                            }
                                        } else {
                                            // iOS16-COMPAT: Remove when minimum target is iOS 17
                                            Color.clear.onAppear {
                                                checkTruncation(fullHeight: fullTextGeometry.size.height, truncatedHeight: truncatedGeometry.size.height)
                                            }
                                            .onChange(of: lineLimit) { _ in
                                                checkTruncation(fullHeight: fullTextGeometry.size.height, truncatedHeight: truncatedGeometry.size.height)
                                            }
                                        }
                                    }
                                )
                                .hidden()
                        }
                    )
            )
    }

    private func checkTruncation(fullHeight: CGFloat, truncatedHeight: CGFloat) {
        let isTruncatedNow = fullHeight > truncatedHeight
        if isTruncated != isTruncatedNow {
            isTruncated = isTruncatedNow
        }
    }
}
