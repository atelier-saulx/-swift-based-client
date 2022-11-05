// swift-tools-version:5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-based-client",
    platforms: [
        .iOS(.v13), .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "BasedClient",
            targets: ["BasedClient"]),
    ],
    dependencies: [
    ],
    targets: [
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
                .target(name: "NakedJson"),
            ]
        ),
        .testTarget(
            name: "BasedClientTests",
            dependencies: [
                "BasedClient",
                .target(name: "NakedJson"),
            ]
        ),
    ]
)
