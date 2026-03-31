//
//  File.swift
//  ImageLoader
//
//  Created by YuriyFpc on 05.02.2026.
//

#if canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias PlatformImage = NSImage
#endif
