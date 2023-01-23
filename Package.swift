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
        .binaryTarget(name: "Based", url: "https://github.com/atelier-saulx/based-universal/releases/download/v1.0.1/based-universal-v1.0.1-xcframework.zip", checksum: "3216f95099385a420b9311ff64bb832425173baee325595e0a45341aa2fcd3e3"),
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
