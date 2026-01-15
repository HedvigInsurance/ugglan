import Foundation
import ProjectDescription

public enum ExternalDependencies: CaseIterable {
    case kingfisher
    case apollo
    case apolloIosCodegen
    case dynamiccolor
    case disk
    case snapkit
    case markdownkit
    case reveal
    case datadog
    case umbrella
    case tagkit
    case introspect
    case svgkit
    case unleashProxyClientSwift
    case argumentParser
    case hero
    case presentableStore
    case environment
    case logger
    case automaticLog
    public var isTestDependency: Bool { false }

    public var isDevDependency: Bool { false }

    public var isResourceBundledDependency: Bool { false }

    public var isAppDependency: Bool { self == .datadog }

    public var isCoreDependency: Bool {
        !isTestDependency && !isDevDependency && !isResourceBundledDependency && !isAppDependency
            && self != .apolloIosCodegen
    }

    public func swiftPackages() -> [Package] {
        switch self {
        case .hero: return [.package(url: "https://github.com/HeroTransitions/Hero", .upToNextMajor(from: "1.6.4"))]
        case .apollo:
            return [.package(url: "https://github.com/apollographql/apollo-ios", .upToNextMajor(from: "2.0.0"))]
        case .dynamiccolor:
            return [
                .package(url: "https://github.com/yannickl/DynamicColor", .upToNextMajor(from: "5.0.1"))
            ]
        case .disk:
            return [.package(url: "https://github.com/HedvigInsurance/Disk", .upToNextMajor(from: "0.6.5"))]
        case .kingfisher:
            return [.package(url: "https://github.com/onevcat/Kingfisher", .upToNextMajor(from: "8.1.0"))]
        case .snapkit:
            return [.package(url: "https://github.com/SnapKit/SnapKit", .upToNextMajor(from: "5.7.1"))]
        case .markdownkit:
            return [
                .package(
                    url: "https://github.com/bmoliveira/MarkdownKit",
                    .upToNextMajor(from: "1.7.3")
                )
            ]
        case .reveal: return []
        case .datadog:
            return [.package(url: "https://github.com/DataDog/dd-sdk-ios.git", .exact("2.25.0"))]
        case .umbrella:
            return [
                .package(url: "https://github.com/HedvigInsurance/umbrella.git", .exact("0.0.20250707133019"))
            ]
        case .tagkit:
            return [
                .package(url: "https://github.com/danielsaidi/TagKit.git", .exact("0.4.1"))
            ]
        case .introspect:
            return [
                .package(url: "https://github.com/siteline/SwiftUI-Introspect", .exact("1.3.0"))
            ]
        case .svgkit:
            return [
                .package(url: "https://github.com/SVGKit/SVGKit", .branch("3.x"))
            ]
        case .unleashProxyClientSwift:
            return [
                .package(url: "https://github.com/Unleash/unleash-proxy-client-swift", .upToNextMajor(from: "2.2.0"))
            ]
        case .apolloIosCodegen:
            return [
                .package(url: "https://github.com/apollographql/apollo-ios-codegen", .upToNextMajor(from: "2.0.0"))
            ]
        case .argumentParser:
            return [
                .package(url: "https://github.com/apple/swift-argument-parser", .exact(.init(stringLiteral: "1.6.2")))
            ]
        case .presentableStore:
            return [
                .package(path: .relativeToRoot("LocalModules/PresentableStore"))
            ]
        case .environment:
            return [
                .package(path: .relativeToRoot("LocalModules/Environment"))
            ]
        case .logger:
            return [
                .package(path: .relativeToRoot("LocalModules/Logger"))
            ]
        case .automaticLog:
            return [
                .package(path: .relativeToRoot("LocalModules/AutomaticLog"))
            ]
        }
    }

    public func targetDependencies() -> [TargetDependency] {
        switch self {
        case .hero: return [.package(product: "Hero")]
        case .kingfisher: return [.package(product: "Kingfisher")]
        case .apollo: return [.package(product: "ApolloWebSocket"), .package(product: "Apollo")]
        case .dynamiccolor: return [.package(product: "DynamicColor")]
        case .disk: return [.package(product: "Disk")]
        case .snapkit: return [.package(product: "SnapKit")]
        case .markdownkit: return [.package(product: "MarkdownKit")]
        case .reveal:
            let path = Path(
                "\(FileManager.default.homeDirectoryForCurrentUser.path)/Library/Application Support/Reveal/RevealServer/RevealServer.xcframework"
            )
            let destinationPath =
                "\(FileManager.default.currentDirectoryPath)/Dependencies/CoreDependencies/RevealServer.xcframework"

            guard FileManager.default.fileExists(atPath: path.pathString) else {
                return []
            }

            if !FileManager.default.fileExists(atPath: destinationPath) {
                try! FileManager.default.copyItem(
                    atPath: path.pathString,
                    toPath:
                        "\(FileManager.default.currentDirectoryPath)/Dependencies/CoreDependencies/RevealServer.xcframework"
                )
            }

            return [
                .xcframework(
                    path: "RevealServer.xcframework"
                )
            ]
        case .datadog:
            return [
                .package(product: "DatadogCrashReporting"),
                .package(product: "DatadogLogs"),
                .package(product: "DatadogCore"),
                .package(product: "DatadogRUM"),
                .package(product: "DatadogTrace"),
            ]
        case .umbrella:
            return [
                .package(product: "HedvigShared")
            ]
        case .tagkit:
            return [
                .package(product: "TagKit")
            ]
        case .introspect:
            return [.package(product: "SwiftUIIntrospect")]
        case .svgkit:
            return [.package(product: "SVGKit")]
        case .unleashProxyClientSwift:
            return [.package(product: "UnleashProxyClientSwift")]
        case .apolloIosCodegen:
            return [.package(product: "ApolloIosCodegen")]
        case .argumentParser:
            return [.package(product: "ArgumentParser")]
        case .presentableStore:
            return [.package(product: "PresentableStore")]
        case .environment:
            return [.package(product: "Environment")]
        case .logger:
            return [.package(product: "Logger")]
        case .automaticLog:
            return [.package(product: "AutomaticLog")]
        }
    }
}

extension Project {
    public static func dependenciesFramework(
        name: String,
        externalDependencies: [ExternalDependencies],
        sdks: [String] = []
    ) -> Project {
        let frameworkConfigurations: [Configuration] = [
            .debug(
                name: "Debug",
                settings: ["SWIFT_VERSION": "6.0.2"],
                xcconfig: .relativeToRoot("Configurations/iOS/iOS-Framework-Debug.xcconfig")
            ),
            .release(
                name: "Release",
                settings: ["SWIFT_VERSION": "6.0.2"],
                xcconfig: .relativeToRoot("Configurations/iOS/iOS-Framework-Release.xcconfig")
            ),
        ]

        let projectConfigurations: [Configuration] = [
            .debug(
                name: "Debug",
                settings: ["SWIFT_VERSION": "6.0.2"],
                xcconfig: .relativeToRoot("Configurations/Base/Configurations/Debug.xcconfig")
            ),
            .release(
                name: "Release",
                settings: ["SWIFT_VERSION": "6.0.2"],
                xcconfig: .relativeToRoot("Configurations/Base/Configurations/Release.xcconfig")
            ),
        ]

        let dependencies: [TargetDependency] = [
            externalDependencies.map { externalDependency in externalDependency.targetDependencies() }
                .flatMap { $0 }, sdks.map { sdk in .sdk(name: sdk, type: .framework) },
        ]
        .flatMap { $0 }
        let packages = externalDependencies.map { externalDependency in externalDependency.swiftPackages() }
            .flatMap { $0 }

        return Project(
            name: name,
            organizationName: "Hedvig",
            options: .options(
                disableBundleAccessors: true,
                disableSynthesizedResourceAccessors: true
            ),
            packages: packages,
            settings: .settings(configurations: projectConfigurations),
            targets: [
                Target.target(
                    name: name,
                    destinations: .iOS,
                    product: .framework,
                    bundleId: "com.hedvig.\(name)",
                    deploymentTargets: .iOS("16.0"),
                    infoPlist: .default,
                    sources: ["Sources/**/*.swift"],
                    resources: [],
                    dependencies: dependencies,
                    settings: .settings(base: [:], configurations: frameworkConfigurations)
                )
            ],
            schemes: [
                Scheme.scheme(
                    name: name,
                    shared: true,
                    buildAction: BuildAction.buildAction(targets: [TargetReference(stringLiteral: name)]),
                    testAction: nil,
                    runAction: nil
                )
            ]
        )
    }
}
