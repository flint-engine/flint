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
        .package(url: "https://github.com/flintbox/Bouncer", from: "0.1.3"),
        .package(url: "https://github.com/swift-cli/motor", from: "0.1.3"),
        .package(url: "https://github.com/flintbox/Work", from: "0.1.1"),
        .package(url: "https://github.com/swift-cli/ansi-escape-code", from: "0.1.2"),
        .package(url: "https://github.com/jasonnam/PathFinder", .branch("develop")),
        .package(url: "https://github.com/jpsim/Yams.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Flint",
            dependencies: ["Bouncer", "Motor", "Work", "ANSIEscapeCode", "PathFinder", "Yams"]),
    ]
)
