//
//  AssetImageContent.swift
//  TerrificCarouselSDK
//

import SwiftUI
import ImageLoader

// MARK: - AssetImageContent
/// Shared image loading view used by both Feed and Detail asset cards.
/// Displays a cached async image with fill aspect ratio and a skeleton placeholder.
struct AssetImageContent: View {
    let url: URL?
    let size: CGSize

    var body: some View {
        CachedAsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height)
                .clipped()
        } placeholder: {
            ImageSkeleton()
                .frame(width: size.width, height: size.height)
        }
    }
}
