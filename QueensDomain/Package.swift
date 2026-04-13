// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "QueensDomain",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "QueensDomain", targets: ["QueensDomain"]),
    ],
    targets: [
        .target(
            name: "QueensDomain",
            path: "Sources/QueensDomain"
        ),
        .testTarget(
            name: "QueensDomainTests",
            dependencies: ["QueensDomain"],
            path: "Tests/QueensDomainTests"
        ),
    ]
)
