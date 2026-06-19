// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "sim-deeplink-tester",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "simdpl", targets: ["simdpl"]),
        .executable(name: "SimDeeplink", targets: ["SimDeeplink"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0")
    ],
    targets: [
        .target(
            name: "SimctlCore"
        ),
        .executableTarget(
            name: "simdpl",
            dependencies: [
                "SimctlCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .executableTarget(
            name: "SimDeeplink",
            dependencies: ["SimctlCore"]
        )
    ]
)
