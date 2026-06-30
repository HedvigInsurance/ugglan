// swift-tools-version: 6.1
import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "AppStateContainer",
    platforms: [.macOS(.v11), .iOS(.v16), .tvOS(.v16), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "AppStateContainer",
            targets: ["AppStateContainer"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "602.0.0-latest")
    ],
    targets: [
        .macro(
            name: "AppStateContainerMacros",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
            ]
        ),
        .target(name: "AppStateContainer", dependencies: ["AppStateContainerMacros"]),
        .testTarget(
            name: "AppStateContainerMacrosTests",
            dependencies: [
                "AppStateContainerMacros",
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
