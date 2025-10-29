// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Cockle",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(name: "Cockle", targets: ["Cockle"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-subprocess", from: "0.2.1"),
    ],
    targets: [
        .target(
            name: "Cockle",
            dependencies: [
                .product(name: "Subprocess", package: "swift-subprocess"),
            ]
        ),
        .testTarget(
            name: "CockleTests",
            dependencies: [
                "Cockle",
            ]
        ),
    ]
)
