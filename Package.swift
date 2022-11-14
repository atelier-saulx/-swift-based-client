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
            targets: ["BasedClient"])
    ],
    dependencies: [
        
    ],
    targets: [
        .binaryTarget(name: "Based", path: "Sources/BasedCplusplusClient/based.zip"),
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
    ]
)
