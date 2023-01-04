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
        .binaryTarget(name: "Based", url: "https://github.com/atelier-saulx/based-universal/releases/download/v1.0.0a/based-universal-v1.0.0-xcframework.zip", checksum: "c1b431b51eb3529ade9dc66159965af4af8e39130e87b1d4519b7402ee5e60d9"),
//        .binaryTarget(
//            name: "Based",
//            path: "Sources/BasedCplusplusClient/Based.xcframework"),
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
