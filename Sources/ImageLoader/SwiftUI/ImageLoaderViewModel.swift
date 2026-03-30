//
//  ImageLoaderViewModel.swift
//  ImageLoader
//

import Foundation
import Combine

// MARK: - ImageLoaderViewModel
@MainActor
public final class ImageLoaderViewModel: ObservableObject {

    // MARK: - Published
    @Published
    public private(set) var state: ImageLoadingState = .idle

    // MARK: - Properties
    private let imageLoader: ImageLoaderProtocol
    private var loadTask: Task<Void, Never>?
    private var currentURL: URL?

    // MARK: - Init
    public init(imageLoader: ImageLoaderProtocol = ImageLoader.shared) {
        self.imageLoader = imageLoader
    }

    // MARK: - Public Methods
    public func load(from url: URL) {
        // Avoid reloading the same URL to prevent flicker
        if currentURL == url {
            if case .loaded = state {
                return
            }
            if case .loading = state {
                return
            }
        }

        // Cancel any existing load
        loadTask?.cancel()

        currentURL = url
        state = .loading

        loadTask = Task {
            let image = await imageLoader.loadImage(from: url)

            guard !Task.isCancelled else { return }

            if let image {
                state = .loaded(image)
            } else {
                state = .failed(ImageLoaderError.loadFailed)
            }
        }
    }

    public func load(from urlString: String) {
        guard let url = URL(string: urlString) else {
            state = .failed(ImageLoaderError.invalidURL)
            return
        }
        load(from: url)
    }

    public func cancel() {
        loadTask?.cancel()
        loadTask = nil
        currentURL = nil
        state = .idle
    }

    // MARK: - Test Helpers

    /// Returns whether a load task is currently running
    public var isLoading: Bool {
        if case .loading = state {
            return true
        }
        return false
    }

    /// Returns the loaded image if available
    public var loadedImage: PlatformImage? {
        if case .loaded(let image) = state {
            return image
        }
        return nil
    }

    /// Returns the error if in failed state
    public var error: Error? {
        if case .failed(let error) = state {
            return error
        }
        return nil
    }
}
