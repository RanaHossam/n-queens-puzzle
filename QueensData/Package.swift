// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "QueensData",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "QueensData", targets: ["QueensData"]),
    ],
    dependencies: [
        .package(path: "../QueensDomain"),
    ],
    targets: [
        .target(
            name: "QueensData",
            dependencies: ["QueensDomain"],
            path: "Sources/QueensData"
        ),
        .testTarget(
            name: "QueensDataTests",
            dependencies: ["QueensData"],
            path: "Tests/QueensDataTests"
        ),
    ]
)
