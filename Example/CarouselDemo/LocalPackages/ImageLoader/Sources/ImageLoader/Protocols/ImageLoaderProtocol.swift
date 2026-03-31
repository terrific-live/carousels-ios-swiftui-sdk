//
//  ImageLoaderProtocol.swift
//  ImageLoader
//

import Foundation

// MARK: - ImageLoaderProtocol
public protocol ImageLoaderProtocol: Actor {
    func loadImage(from url: URL) async -> PlatformImage?
    func loadImage(from urlString: String) async -> PlatformImage?
    func cancelLoad(for url: URL)
    func cancelAllLoads()
}
