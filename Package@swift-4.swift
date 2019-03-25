// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "PrettyColors",
    products: [
        .library(name: "PrettyColors", targets: ["PrettyColors"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "PrettyColors", path: "Source"),
        .testTarget(name: "UnitTests", dependencies: ["PrettyColors"]),
    ]
)
