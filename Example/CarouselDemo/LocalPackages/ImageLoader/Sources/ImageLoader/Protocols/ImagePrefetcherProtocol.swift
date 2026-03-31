//
//  ImagePrefetcherProtocol.swift
//  ImageLoader
//

import Foundation

// MARK: - ImagePrefetcherProtocol
public protocol ImagePrefetcherProtocol: Actor {
    func prefetch(urls: [URL])
    func prefetch(urlStrings: [String])
    func cancelPrefetching(for urls: [URL])
    func cancelAllPrefetching()
}

// MARK: - HasImageURL Protocol
/// Protocol for items that have an image URL
public protocol HasImageURL {
    var imageURL: URL? { get }
}

// Extension for items with string URLs
public extension HasImageURL {
    var imageURLString: String? {
        imageURL?.absoluteString
    }
}
