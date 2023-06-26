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
        .binaryTarget(name: "Based", url: "https://github.com/atelier-saulx/based-universal/releases/download/v2.1.0/based-universal-v2.1.0-xcframework.zip", checksum: "025afd018f8ce01aef5e4401b7072d24aa3ffd7e739d0e761dea3d78e591beda"),
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
