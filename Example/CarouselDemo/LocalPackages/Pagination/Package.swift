// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Pagination",
    platforms: [
        .iOS(.v16),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Pagination",
            targets: ["Pagination"]
        ),
    ],
    targets: [
        .target(
            name: "Pagination"
        ),
        .testTarget(
            name: "PaginationTests",
            dependencies: ["Pagination"]
        ),
    ]
)
