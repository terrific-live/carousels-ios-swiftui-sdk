// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ImageLoader",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "ImageLoader",
            targets: ["ImageLoader"]
        ),
    ],
    targets: [
        .target(
            name: "ImageLoader"
        ),
        .testTarget(
            name: "ImageLoaderTests",
            dependencies: ["ImageLoader"]
        ),
    ]
)
