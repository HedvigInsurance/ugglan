import PackageDescription

let package = Package(
    name: "PresentableStore",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PresentableStore",
            targets: ["PresentableStore"]
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PresentableStore"
        ),
        .testTarget(
            name: "PresentableStoreTests",
            dependencies: ["PresentableStore"]
        ),
    ]
)
