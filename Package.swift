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
        .package(path: "../swift-index-primitives"),
        .package(path: "../swift-cyclic-primitives"),
        .package(path: "../swift-property-primitives"),
        .package(path: "../swift-sequence-primitives"),
    ],
    targets: [
        .target(
            name: "Range Primitives Core",
            dependencies: [
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Cyclic Primitives", package: "swift-cyclic-primitives"),
                .product(name: "Property Primitives", package: "swift-property-primitives"),
                .product(name: "Sequence Primitives", package: "swift-sequence-primitives"),
            ]
        ),
        .target(
            name: "Range Primitives",
            dependencies: [
                "Range Primitives Core",
                "Range Primitives Standard Library Integration",
            ]
        ),
        .target(
            name: "Range Primitives Standard Library Integration",
            dependencies: [
                "Range Primitives Core",
            ]
        ),
        .target(
            name: "Range Primitives Test Support",
            dependencies: [
                "Range Primitives",
                .product(name: "Index Primitives Test Support", package: "swift-index-primitives"),
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
    let settings: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableExperimentalFeature("Lifetimes"),
        .strictMemorySafety(),
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + settings
}
