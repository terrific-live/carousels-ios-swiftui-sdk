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
                                        Color.clear.onAppear {
                                            // Compare heights to detect truncation
                                            let isTruncatedNow = fullTextGeometry.size.height > truncatedGeometry.size.height
                                            if isTruncated != isTruncatedNow {
                                                isTruncated = isTruncatedNow
                                            }
                                        }
                                        .onChange(of: lineLimit) { _, _ in
                                            let isTruncatedNow = fullTextGeometry.size.height > truncatedGeometry.size.height
                                            if isTruncated != isTruncatedNow {
                                                isTruncated = isTruncatedNow
                                            }
                                        }
                                    }
                                )
                                .hidden()
                        }
                    )
            )
    }
}
