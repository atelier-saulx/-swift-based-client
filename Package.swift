// swift-tools-version:5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription


let package = Package(
    name: "swift-based-client",
    platforms: [
        .iOS(.v15), .macOS(.v12),
    ],
    products: [
        .library(
            name: "BasedClient",
            type: .dynamic,
            targets: ["BasedClient"])
    ],
    targets: [
        .binaryTarget(
            name: "Based",
            url: "https://github.com/atelier-saulx/based-universal/releases/download/v2.1.6/based-universal-v2.1.6-xcframework.zip",
            checksum: "40d1d754633942985f01253db14b10bde4534ad85538f1f0dc80c20305356eb4"
        ),
        .target(
            name: "BasedOBJCWrapper",
            dependencies: [
                .target(name: "Based")
            ],
            path: "Sources/BasedOBJCWrapper"
        ),
        .target(
            name: "NakedJson"
        ),
        .testTarget(
            name: "NakedJsonTests",
            dependencies: [
                "NakedJson",
            ]
        ),
        .target(
            name: "BasedClient",
            dependencies: [
                .target(name: "BasedOBJCWrapper"),
                .target(name: "NakedJson"),
            ]
        ),
        .testTarget(
            name: "BasedClientTests",
            dependencies: [
                "BasedClient",
                .target(name: "BasedOBJCWrapper"),
                .target(name: "NakedJson"),
            ]
        )
    ],
    cxxLanguageStandard: .gnucxx20
)
