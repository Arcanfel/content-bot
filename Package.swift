// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "content-bot",
  platforms: [
    .macOS(.v10_12),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    // .package(url: "https://github.com/zmeyc/telegram-bot-swift.git", from: "1.1.0"),
    .package(url: "https://github.com/iwasrobbed/Down.git", from: "0.8.5"),
    .package(url: "https://github.com/orta/Komondor.git", from: "1.0.4"),
    .package(url: "https://github.com/realm/SwiftLint.git", from: "0.33.0"),
    .package(url: "https://github.com/nicklockwood/SwiftFormat.git", from: "0.40.10"),
    .package(url: "https://github.com/IBM-Swift/Kitura.git", from: "2.7.0"),
    .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", from: "1.8.1"),
    .package(url: "https://github.com/JohnSundell/Files.git", from: "3.1.0"),
    .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "5.0.0"),
    .package(url: "https://github.com/IBM-Swift/BlueCryptor.git", from: "1.0.31"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages which this package depends on.
    .target(name: "blog-bot", dependencies: [
      "Kitura",
      "Down",
      "HeliumLogger",
      "Files",
      "RxSwift",
      "RxCocoa",
      "Cryptor",
    ]),
    .testTarget(name: "blog-botTests", dependencies: ["blog-bot"]),
  ]
)

#if canImport(PackageConfig)
  import PackageConfig

  let config = PackageConfiguration([
    "komondor": [
      "pre-push": "swift test",
      "pre-commit": [
        "swift test",
        "swift run swiftformat .",
        "swift run swiftlint autocorrect --path Sources/",
        "git add .",
      ],
    ],
    "rocket": [
      "after": [
        "push",
      ],
    ],
  ]).write()
#endif
