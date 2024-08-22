// swift-tools-version: 5.10


import PackageDescription

let package = Package(
    name: "StoreContainer",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "StoreContainer",
            targets: ["StoreContainer"]
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "StoreContainer"
        ),
        .testTarget(
            name: "StoreContainerTests",
            dependencies: ["StoreContainer"]
        ),
    ]
)
