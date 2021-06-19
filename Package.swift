// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Solana",
    platforms: [.iOS(.v11), .macOS(.v10_12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Solana",
            targets: ["Solana"]),
        .library(
            name: "RxSolana",
            targets: ["RxSolana"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "TweetNacl", url: "https://github.com/bitmark-inc/tweetnacl-swiftwrap.git", from: "1.0.2"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.2.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.4.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Solana",
            dependencies: ["TweetNacl", "CryptoSwift"],
            resources: [ .process("Resources")
            ]
        ),
        .target(
            name: "RxSolana",
            dependencies: ["TweetNacl", "Solana", "RxSwift", "CryptoSwift", .product(name: "RxCocoa", package: "RxSwift")],
            resources: [ .process("Resources")
            ]
        ),
        .testTarget(
            name: "SolanaTests",
            dependencies: ["RxSolana", "TweetNacl", "RxSwift", "CryptoSwift", .product(name: "RxBlocking", package: "RxSwift")],
            resources: [ .process("Resources")
            ]
        )
    ]
)
