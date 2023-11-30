// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NukeWebP",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "NukeWebP",
            targets: ["NukeWebP"]),
        .library(
            name: "NukeWebPBasic",
            targets: ["NukeWebPBasic"]),
        .library(
            name: "NukeWebPAdvanced",
            targets: ["NukeWebPAdvanced"]),
        
    ],
    dependencies: [
        .package(url: "https://github.com/kean/Nuke.git", from: "12.0.0"),
        .package(url: "https://github.com/SDWebImage/libwebp-Xcode", from: "1.3.2"),
    ],
    targets: [
        .target(
            name: "NukeWebP",
            dependencies: [
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "libwebp", package: "libwebp-Xcode"),
            ]),
        .target(
            name: "NukeWebPBasic",
            dependencies: [
                .target(name: "NukeWebP")
            ]),
        .target(
            name: "NukeWebPAdvanced",
            dependencies: [
                .target(name: "NukeWebP")
            ]),
        .testTarget(
            name: "NukeWebPTests",
            dependencies: [
                .target(name: "NukeWebP"),
                .target(name: "NukeWebPBasic"),
                .target(name: "NukeWebPAdvanced"),
            ]),
    ]
)
