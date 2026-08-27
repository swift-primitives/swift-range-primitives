// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-range",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Range",
            targets: ["Range"]
        ),
        .library(
            name: "Range Standard Library Integration",
            targets: ["Range Standard Library Integration"]
        ),
        .library(
            name: "Range Apple Foundation Integration",
            targets: ["Range Apple Foundation Integration"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-property.git",
            branch: "main"
        )
    ],
    targets: [
        .target(
            name: "Range",
            dependencies: [
                .product(name: "Property", package: "swift-property")
            ]
        ),
        .target(
            name: "Range Standard Library Integration",
            dependencies: ["Range"]
        ),
        .target(
            name: "Range Apple Foundation Integration",
            dependencies: [
                "Range",
                "Range Standard Library Integration",
            ]
        ),
        .testTarget(
            name: "Range Tests",
            dependencies: [
                "Range"
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
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
