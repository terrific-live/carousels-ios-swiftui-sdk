//
//  ImageLoaderError.swift
//  ImageLoader
//

import Foundation

// MARK: - ImageLoaderError
public enum ImageLoaderError: Error, LocalizedError, Equatable {
    case invalidURL
    case loadFailed
    case timeout
    case httpError(statusCode: Int)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid image URL"
        case .loadFailed:
            return "Failed to load image"
        case .timeout:
            return "Image download timed out"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        }
    }
}
