//
//  File.swift
//  ImageLoader
//
//  Created by YuriyFpc on 05.02.2026.
//

#if canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage

extension UIImage {
    var hasAlphaChannel: Bool {
        guard let alpha = cgImage?.alphaInfo else { return false }
        switch alpha {
        case .first, .last, .premultipliedFirst, .premultipliedLast, .alphaOnly:
            return true
        case .none, .noneSkipFirst, .noneSkipLast:
            return false
        @unknown default:
            return false
        }
    }
}
#elseif canImport(AppKit)
import AppKit
public typealias PlatformImage = NSImage
#endif
