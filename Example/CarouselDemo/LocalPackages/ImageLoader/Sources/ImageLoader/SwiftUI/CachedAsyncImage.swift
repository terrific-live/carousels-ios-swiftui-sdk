//
//  CachedAsyncImage.swift
//  ImageLoader
//

import SwiftUI

// MARK: - CachedAsyncImage
/// A SwiftUI view that loads and caches images asynchronously with skeleton placeholder
public struct CachedAsyncImage<Content: View, Placeholder: View>: View {

    // MARK: - Properties
    @StateObject
    private var viewModel = ImageLoaderViewModel()

    private let url: URL?
    private let contentMode: ContentMode
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder

    // MARK: - Init
    public init(
        url: URL?,
        contentMode: ContentMode = .fill,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.contentMode = contentMode
        self.content = content
        self.placeholder = placeholder
    }

    public init(
        urlString: String?,
        contentMode: ContentMode = .fill,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = urlString.flatMap { URL(string: $0) }
        self.contentMode = contentMode
        self.content = content
        self.placeholder = placeholder
    }

    // MARK: - Body
    public var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                placeholder()

            case .loaded(let platformImage):
                #if canImport(UIKit)
                content(Image(uiImage: platformImage))
                #elseif canImport(AppKit)
                content(Image(nsImage: platformImage))
                #endif

            case .failed:
                placeholder() // Show placeholder on failure too
            }
        }
        .onAppear {
            loadImageIfNeeded()
        }
        .onChange(of: url) { _, _ in
            loadImageIfNeeded()
        }
    }

    // MARK: - Private Methods
    private func loadImageIfNeeded() {
        guard let url else { return }
        viewModel.load(from: url)
    }
}

// MARK: - Convenience Initializers
public extension CachedAsyncImage where Placeholder == ImageSkeleton {

    /// Convenience initializer with default skeleton placeholder
    init(
        url: URL?,
        contentMode: ContentMode = .fill,
        @ViewBuilder content: @escaping (Image) -> Content
    ) {
        self.init(
            url: url,
            contentMode: contentMode,
            content: content,
            placeholder: { ImageSkeleton() }
        )
    }

    /// Convenience initializer with URL string and default skeleton placeholder
    init(
        urlString: String?,
        contentMode: ContentMode = .fill,
        @ViewBuilder content: @escaping (Image) -> Content
    ) {
        self.init(
            url: urlString.flatMap { URL(string: $0) },
            contentMode: contentMode,
            content: content,
            placeholder: { ImageSkeleton() }
        )
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        CachedAsyncImage(
            urlString: "https://picsum.photos/400/300"
        ) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
        .frame(width: 300, height: 200)
        .clipped()
        .cornerRadius(12)

        ImageSkeleton()
            .frame(width: 300, height: 200)
            .cornerRadius(12)
    }
    .padding()
}
