//
//  ImageCacheProtocol.swift
//  ImageLoader
//

import Foundation

// MARK: - ImageCache Protocol
public protocol ImageCacheProtocol: AnyObject, Sendable {
    func image(for url: URL) async -> PlatformImage?
    func insertImage(_ image: PlatformImage?, for url: URL) async
    func removeImage(for url: URL) async
    func removeAllImages() async
}
