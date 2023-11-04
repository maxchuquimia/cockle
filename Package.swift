// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Cockle",
    products: [
        .library(name: "Cockle", targets: ["Cockle"]),
    ],
    targets: [
        .target(name: "Cockle"),
        .testTarget(name: "CockleTests", dependencies: ["Cockle"]),
    ]
)
