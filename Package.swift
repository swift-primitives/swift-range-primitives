// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-range-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "Range Primitives",
            targets: ["Range Primitives"]
        ),
        .library(
            name: "Range Primitives Test Support",
            targets: ["Range Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(path: "../swift-vector-primitives"),
    ],
    targets: [
        .target(
            name: "Range Primitives Core",
            dependencies: [
                .product(name: "Vector Primitives", package: "swift-vector-primitives"),
            ]
        ),
        .target(
            name: "Range Primitives",
            dependencies: [
                "Range Primitives Core",
            ]
        ),
        .target(
            name: "Range Primitives Test Support",
            dependencies: [
                "Range Primitives",
                .product(name: "Vector Primitives Test Support", package: "swift-vector-primitives"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Range Primitives Tests",
            dependencies: [
                "Range Primitives",
                "Range Primitives Test Support",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
