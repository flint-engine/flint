// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "flint",
    products: [
        .executable(
            name: "flint",
            targets: ["Flint"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.7.0"),
        .package(url: "https://github.com/swift-cli/motor", from: "0.1.3"),
        .package(url: "https://github.com/swift-cli/execute", from: "0.1.2"),
        .package(url: "https://github.com/swift-cli/ansi-escape-code", from: "0.1.2"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "6.2.1"),
    ],
    targets: [
        .target(
            name: "Flint",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "Motor",
                "Execute",
                "ANSIEscapeCode",
                "Yams"
            ]
        )
    ]
)
