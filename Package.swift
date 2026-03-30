// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "TerrificCarouselSDK",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "TerrificCarouselSDK",
            targets: ["TerrificCarouselSDK"]
        ),
    ],
    targets: [
        // MARK: - Main SDK Target (Public API)
        .target(
            name: "TerrificCarouselSDK",
            dependencies: [
                "HTTPClient",
                "ImageLoader",
                "MediaPlayback",
                "Pagination"
            ],
            path: "Sources/TerrificCarouselSDK"
        ),

        // MARK: - Internal Targets
        .target(
            name: "HTTPClient",
            path: "Sources/HTTPClient"
        ),
        .target(
            name: "ImageLoader",
            path: "Sources/ImageLoader"
        ),
        .target(
            name: "MediaPlayback",
            path: "Sources/MediaPlayback"
        ),
        .target(
            name: "Pagination",
            path: "Sources/Pagination"
        ),

        // MARK: - Test Targets
        .testTarget(
            name: "TerrificCarouselSDKTests",
            dependencies: ["TerrificCarouselSDK"],
            path: "Tests/TerrificCarouselSDKTests"
        ),
        .testTarget(
            name: "HTTPClientTests",
            dependencies: ["HTTPClient"],
            path: "Tests/HTTPClientTests"
        ),
        .testTarget(
            name: "ImageLoaderTests",
            dependencies: ["ImageLoader"],
            path: "Tests/ImageLoaderTests"
        ),
        .testTarget(
            name: "MediaPlaybackTests",
            dependencies: ["MediaPlayback"],
            path: "Tests/MediaPlaybackTests"
        ),
        .testTarget(
            name: "PaginationTests",
            dependencies: ["Pagination"],
            path: "Tests/PaginationTests"
        )
    ]
)
