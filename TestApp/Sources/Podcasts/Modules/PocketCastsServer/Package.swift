// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PocketCastsServer",
    platforms: [
        .iOS(.v15), .watchOS(.v7)
    ],
    products: [
        .library(
            name: "PocketCastsServer",
            type: .dynamic,
            targets: ["PocketCastsServer"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.0.0"),
        .package(path: "../PocketCastsDataModel/"),
        .package(path: "../PocketCastsUtils/")
    ],
    targets: [
        .target(
            name: "PocketCastsServer",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "PocketCastsDataModel", package: "PocketCastsDataModel"),
                .product(name: "PocketCastsUtils", package: "PocketCastsUtils"),
                "SwiftyJSON"
            ],
            path: "Sources",
            linkerSettings: [
                .linkedFramework("CFNetwork", .when(platforms: [.iOS])),
                .linkedFramework("AuthenticationServices", .when(platforms: [.iOS, .watchOS]))
            ]
        ),
    ]
)
