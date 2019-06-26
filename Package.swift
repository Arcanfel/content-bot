// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "blog-bot",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/zmeyc/telegram-bot-swift.git", from: "1.1.0"),
        .package(url: "https://github.com/iwasrobbed/Down.git", from: "0.8.5"),
        .package(url: "https://github.com/realm/SwiftLint", from: "0.33.0"),
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.40.10"),
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "blog-bot",
            dependencies: []
        ),
        .testTarget(
            name: "blog-botTests",
            dependencies: ["blog-bot"]
        ),
    ]
)
