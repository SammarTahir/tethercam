// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "TSMuxer",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "TSMuxer", targets: ["TSMuxer"]),
    ],
    targets: [
        .target(name: "TSMuxer"),
        .testTarget(name: "TSMuxerTests", dependencies: ["TSMuxer"]),
    ]
)
