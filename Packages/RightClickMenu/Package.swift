// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "RightClickMenu",
    defaultLocalization: "en",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "RightClickMenuShared", targets: ["RightClickMenuShared"]),
        .library(name: "RightClickMenuCore", targets: ["RightClickMenuCore"]),
        .library(name: "RightClickMenuUI", targets: ["RightClickMenuUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/raspu/Highlightr", from: "2.3.0"),
    ],
    targets: [
        .target(name: "RightClickMenuShared"),
        .target(
            name: "RightClickMenuCore",
            dependencies: ["RightClickMenuShared"],
            resources: [.process("Resources")]
        ),
        .target(
            name: "RightClickMenuUI",
            dependencies: [
                "RightClickMenuCore",
                .product(name: "Highlightr", package: "Highlightr"),
            ],
            resources: [.process("Resources")]
        ),

        .testTarget(name: "RightClickMenuSharedTests", dependencies: ["RightClickMenuShared"]),
        .testTarget(name: "RightClickMenuCoreTests", dependencies: ["RightClickMenuCore"]),
        .testTarget(name: "RightClickMenuUITests", dependencies: ["RightClickMenuUI"]),
    ]
)
