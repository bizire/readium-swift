// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PocketCastsUtils",
    platforms: [
        .iOS(.v15), .watchOS(.v7)
    ],
    products: [
        .library(
            name: "PocketCastsUtils",
            type: .dynamic,
            targets: ["PocketCastsUtils"]
        )
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "PocketCastsUtils",
            dependencies: [],
            path: "Sources"
        ),
    ]
)
