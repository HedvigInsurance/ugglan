import Foundation
import ProjectDescription

public enum ExternalDependencies: CaseIterable {
    case kingfisher
    case apollo
    case apolloIosCodegen
    case flow
    case form
    case presentation
    case dynamiccolor
    case disk
    case snapkit
    case markdownkit
    case snapshottesting
    case reveal
    case datadog
    case authlib
    case tagkit
    case introspect
    case svgkit
    case unleashProxyClientSwift
    case argumentParser
    case hero

    public var isTestDependency: Bool { self == .snapshottesting }

    public var isDevDependency: Bool { false }

    public var isResourceBundledDependency: Bool { false }

    public var isAppDependency: Bool { self == .datadog }

    public var isCoreDependency: Bool {
        !isTestDependency && !isDevDependency && !isResourceBundledDependency && !isAppDependency
            && self != .apolloIosCodegen
    }

    public func swiftPackages() -> [Package] {
        switch self {
        case .hero: return [.package(url: "https://github.com/HeroTransitions/Hero", .upToNextMajor(from: "1.6.3"))]
        case .apollo: return [.package(url: "https://github.com/apollographql/apollo-ios", .exact("1.13.0"))]
        case .flow:
            return [.package(url: "https://github.com/HedvigInsurance/Flow", .upToNextMajor(from: "1.8.10"))]
        case .form:
            return [
                .package(
                    url: "https://github.com/HedvigInsurance/Form",
                    .exact("3.1.2")
                )
            ]
        case .presentation:
            return [
                .package(
                    url: "https://github.com/HedvigInsurance/Presentation",
                    .upToNextMajor(from: "3.0.5")
                )
            ]
        case .dynamiccolor:
            return [
                .package(url: "https://github.com/yannickl/DynamicColor", .upToNextMajor(from: "5.0.1"))
            ]
        case .disk:
            return [.package(url: "https://github.com/HedvigInsurance/Disk", .upToNextMajor(from: "0.6.5"))]
        case .kingfisher:
            return [.package(url: "https://github.com/onevcat/Kingfisher", .upToNextMajor(from: "7.12.0"))]
        case .snapkit:
            return [.package(url: "https://github.com/SnapKit/SnapKit", .upToNextMajor(from: "5.7.0"))]
        case .markdownkit:
            return [
                .package(
                    url: "https://github.com/bmoliveira/MarkdownKit",
                    .upToNextMajor(from: "1.7.1")
                )
            ]
        case .snapshottesting:
            return [
                .package(
                    url: "https://github.com/pointfreeco/swift-snapshot-testing",
                    .upToNextMajor(from: "1.9.0")
                )
            ]
        case .reveal: return []
        case .datadog:
            return [.package(url: "https://github.com/DataDog/dd-sdk-ios.git", .exact("2.16.0"))]
        case .authlib:
            return [
                .package(url: "https://github.com/HedvigInsurance/authlib.git", .exact("1.3.2120240730134747"))
            ]
        case .tagkit:
            return [
                .package(url: "https://github.com/danielsaidi/TagKit.git", .exact("0.1.1"))
            ]
        case .introspect:
            return [
                .package(url: "https://github.com/siteline/SwiftUI-Introspect", .exact("0.3.1"))
            ]
        case .svgkit:
            return [
                .package(url: "https://github.com/SVGKit/SVGKit", .branch("3.x"))
            ]
        case .unleashProxyClientSwift:
            return [
                .package(url: "https://github.com/Unleash/unleash-proxy-client-swift", .upToNextMajor(from: "1.1.1"))
            ]
        case .apolloIosCodegen:
            return [
                .package(url: "https://github.com/apollographql/apollo-ios-codegen", .exact("1.13.0"))
            ]
        case .argumentParser:
            return [
                .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "1.3.0"))
            ]
        }
    }

    public func targetDependencies() -> [TargetDependency] {
        switch self {
        case .hero: return [.package(product: "Hero")]
        case .kingfisher: return [.package(product: "Kingfisher")]
        case .apollo: return [.package(product: "ApolloWebSocket"), .package(product: "Apollo")]
        case .flow: return [.package(product: "Flow")]
        case .form: return [.package(product: "Form")]
        case .presentation:
            return [.package(product: "Presentation"), .package(product: "PresentationDebugSupport")]
        case .dynamiccolor: return [.package(product: "DynamicColor")]
        case .disk: return [.package(product: "Disk")]
        case .snapkit: return [.package(product: "SnapKit")]
        case .markdownkit: return [.package(product: "MarkdownKit")]
        case .snapshottesting: return [.package(product: "SnapshotTesting")]
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
        case .authlib:
            return [
                .package(product: "authlib")
            ]
        case .tagkit:
            return [
                .package(product: "TagKit")
            ]
        case .introspect:
            return [.package(product: "Introspect")]
        case .svgkit:
            return [.package(product: "SVGKit")]
        case .unleashProxyClientSwift:
            return [.package(product: "UnleashProxyClientSwift")]
        case .apolloIosCodegen:
            return [.package(product: "ApolloIosCodegen")]
        case .argumentParser:
            return [.package(product: "ArgumentParser")]
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
                settings: [String: SettingValue](),
                xcconfig: .relativeToRoot("Configurations/iOS/iOS-Framework.xcconfig")
            ),
            .release(
                name: "Release",
                settings: [String: SettingValue](),
                xcconfig: .relativeToRoot("Configurations/iOS/iOS-Framework.xcconfig")
            ),
        ]

        let projectConfigurations: [Configuration] = [
            .debug(
                name: "Debug",
                settings: [String: SettingValue](),
                xcconfig: .relativeToRoot("Configurations/Base/Configurations/Debug.xcconfig")
            ),
            .release(
                name: "Release",
                settings: [String: SettingValue](),
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
                Target(
                    name: name,
                    platform: .iOS,
                    product: .framework,
                    bundleId: "com.hedvig.\(name)",
                    deploymentTarget: .iOS(targetVersion: "15.0", devices: [.iphone, .ipad]),
                    infoPlist: .default,
                    sources: ["Sources/**/*.swift"],
                    resources: [],
                    dependencies: dependencies,
                    settings: .settings(base: [:], configurations: frameworkConfigurations)
                )
            ],
            schemes: [
                Scheme(
                    name: name,
                    shared: true,
                    buildAction: BuildAction(targets: [TargetReference(stringLiteral: name)]),
                    testAction: nil,
                    runAction: nil
                )
            ]
        )
    }
}
