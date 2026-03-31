// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MediaPlayback",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MediaPlayback",
            targets: ["MediaPlayback"]
        ),
    ],
    targets: [
        .target(
            name: "MediaPlayback"
        ),
        .testTarget(
            name: "MediaPlaybackTests",
            dependencies: ["MediaPlayback"]
        ),
    ]
)
