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
        .binaryTarget(name: "Based", url: "https://github.com/atelier-saulx/based-universal/releases/download/v2.1.2/based-universal-v2.1.2-xcframework.zip", checksum: "22c2ea1ea05750a891b2dfb224c2321d2c3b75e56c168e22c7370b566e012e4b"),
//        .binaryTarget(
//            name: "Based",
//            path: "Based.xcframework"),
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
