// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension Target.Dependency {
    static var tca: Self {
        .product(
            name: "ComposableArchitecture",
            package: "swift-composable-architecture"
        )
    }
    static var appService: Self {
        .product(
            name: "AppService",
            package: "AppService"
        )
    }
}

let package = Package(
    name: "AcharyaPrasantAssementRatneshPackage",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "AppFeature",
            targets: ["AppFeature"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            .upToNextMajor(from: "1.0.0")
        ),
        .package(
            url: "https://github.com/ratnesh-jain/AppService",
            .upToNextMajor(from: "0.0.1")
        ),
    ],
    targets: [
        .target(name: "Models", dependencies: []),
        .target(name: "UIUtilities", dependencies: []),
        .target(
            name: "ServiceClient",
            dependencies: [
                "Models",
                .tca,
                .appService
            ]
        ),
        .target(
            name: "MediaCoveragesFeature",
            dependencies: [
                .tca,
                "ServiceClient",
                "UIUtilities"
            ]
        ),
        .target(
            name: "MediaCoverageDetailsFeature",
            dependencies: [
                .tca,
                "Models",
                "UIUtilities"
            ]
        ),
        .target(
            name: "AppFeature",
            dependencies: [
                "MediaCoveragesFeature",
                "MediaCoverageDetailsFeature"
            ]
        ),
    ]
)
