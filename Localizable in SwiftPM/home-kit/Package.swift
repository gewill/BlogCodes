// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HomeKit",
    defaultLocalization: "en",
    platforms: [.macOS(.v11),
                .iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HomeKit",
            type: .dynamic,
            targets: ["HomeKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mac-cain13/R.swift.git", .upToNextMajor(from: "7.0.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "HomeKit",
            dependencies: [
                .product(name: "RswiftLibrary", package: "R.swift"),
            ],
            path: "Sources/HomeKit",
            resources: [
                .process("Resources"),
            ],
            plugins: [
                .plugin(name: "RswiftGeneratePublicResources", package: "R.swift"),
            ]),
        .testTarget(
            name: "HomeKitTests",
            dependencies: ["HomeKit"]),
    ])
