// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PocketCastsDataModel",
    platforms: [
        .iOS(.v15), .watchOS(.v7)
    ],
    products: [
        .library(
            name: "PocketCastsDataModel",
            type: .dynamic,
            targets: ["PocketCastsDataModel"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ccgus/fmdb.git", from: "2.0.0"),
        .package(path: "../PocketCastsUtils/")
    ],
    targets: [
        .target(
            name: "PocketCastsDataModel",
            dependencies: [
                .product(name: "FMDB", package: "FMDB"),
                .product(name: "PocketCastsUtils", package: "PocketCastsUtils")
            ],
            path: "Sources"
        ),
    ]
)

