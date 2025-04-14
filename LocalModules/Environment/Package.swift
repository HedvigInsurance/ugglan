// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Environment",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Environment",
            targets: ["Environment"]
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Environment"
        ),
        .testTarget(
            name: "EnvironmentTests",
            dependencies: ["Environment"]
        ),
    ]
)
