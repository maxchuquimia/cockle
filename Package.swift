// swift-tools-version: 5.9

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
        .package(url: "https://github.com/swiftlang/swift-subprocess", exact: "0.1.0"),
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
