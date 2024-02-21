// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Solana",
    platforms: [.iOS(.v11), .macOS(.v10_12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Solana",
            targets: ["Solana"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "TweetNacl", url: "https://github.com/bitmark-inc/tweetnacl-swiftwrap.git", from: "1.0.2"),
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.0"),
        .package(name: "Beet", url: "https://github.com/metaplex-foundation/beet-swift.git", from: "1.0.2"),
        .package(name: "secp256k1", url: "https://github.com/GigaBitcoin/secp256k1.swift", .upToNextMinor(from: "0.10.0")),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Solana",
            dependencies: ["TweetNacl", "Starscream", "secp256k1", "Beet"]
        ),
        .testTarget(
            name: "SolanaTests",
            dependencies: ["Solana", "TweetNacl", "Starscream", "secp256k1", "Beet"],
            resources: [.copy("Resources/Mocks")]
        )
    ]
)
