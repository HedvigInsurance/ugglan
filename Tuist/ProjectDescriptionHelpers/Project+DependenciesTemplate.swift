import Foundation
import ProjectDescription

public enum ExternalDependencies: CaseIterable {
    case adyen
    case firebase
    case kingfisher
    case apollo
    case flow
    case form
    case presentation
    case dynamiccolor
    case disk
    case snapkit
    case markdownkit
    case runtime
    case hero
    case snapshottesting
    case shake
    case reveal
    case datadog
    case hAnalytics
    case odysseyKit
    case authlib

    public var isTestDependency: Bool { self == .snapshottesting }

    public var isDevDependency: Bool { false }

    public var isResourceBundledDependency: Bool { self == .adyen }

    public var isAppDependency: Bool { self == .firebase || self == .datadog }

    public var isCoreDependency: Bool {
        !isTestDependency && !isDevDependency && !isResourceBundledDependency && !isAppDependency
    }

    public func swiftPackages() -> [Package] {
        switch self {
        case .adyen: return [.package(url: "https://github.com/Adyen/adyen-ios", .exact("4.7.2"))]
        case .runtime:
            return [.package(url: "https://github.com/wickwirew/Runtime", .exact("2.2.2"))]
        case .firebase:
            return [
                .package(
                    url: "https://github.com/firebase/firebase-ios-sdk",
                    .upToNextMajor(from: "8.8.0")
                )
            ]
        case .apollo: return [.package(url: "https://github.com/apollographql/apollo-ios", .exact("0.51.2"))]
        case .flow:
            return [.package(url: "https://github.com/HedvigInsurance/Flow", .upToNextMajor(from: "1.8.7"))]
        case .form:
            return [
                .package(
                    url: "https://github.com/HedvigInsurance/Form",
                    .exact("3.1.0")
                )
            ]
        case .presentation:
            return [
                .package(
                    url: "https://github.com/HedvigInsurance/Presentation",
                    .exact("2.0.20")
                )
            ]
        case .dynamiccolor:
            return [
                .package(url: "https://github.com/yannickl/DynamicColor", .upToNextMajor(from: "5.0.1"))
            ]
        case .disk:
            return [.package(url: "https://github.com/HedvigInsurance/Disk", .upToNextMajor(from: "0.6.5"))]
        case .kingfisher:
            return [.package(url: "https://github.com/onevcat/Kingfisher", .upToNextMajor(from: "7.2.2"))]
        case .snapkit:
            return [.package(url: "https://github.com/SnapKit/SnapKit", .upToNextMajor(from: "5.6.0"))]
        case .markdownkit:
            return [
                .package(
                    url: "https://github.com/bmoliveira/MarkdownKit",
                    .upToNextMajor(from: "1.7.1")
                )
            ]
        case .hero: return [.package(url: "https://github.com/HeroTransitions/Hero", .exact("1.5.0"))]
        case .snapshottesting:
            return [
                .package(
                    url: "https://github.com/pointfreeco/swift-snapshot-testing",
                    .upToNextMajor(from: "1.9.0")
                )
            ]
        case .shake: return [.package(url: "https://github.com/shakebugs/shake-ios", .branch("master"))]
        case .reveal: return []
        case .datadog:
            return [.package(url: "https://github.com/DataDog/dd-sdk-ios.git", .exact("1.10.0"))]
        case .hAnalytics:
            return [
                .package(url: "https://github.com/HedvigInsurance/hAnalytics.git", .exact("0.276.0"))
            ]
        case .odysseyKit:
            return [
                .package(url: "https://github.com/HedvigInsurance/OdysseyKit.git", .exact("1.156.0"))
            ]
        case .authlib:
            return [
                .package(url: "https://github.com/HedvigInsurance/authlib.git", .exact("0.0.15"))
            ]
        }
    }

    public func targetDependencies() -> [TargetDependency] {
        switch self {
        case .adyen:
            return [
                .package(product: "Adyen"), .package(product: "AdyenCard"),
                .package(product: "AdyenDropIn"),
            ]
        case .firebase:
            return [
                .package(product: "FirebaseAnalytics"),
                .package(product: "FirebaseMessaging"),
                .package(product: "FirebaseDynamicLinks"),
            ]
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
        case .runtime: return [.package(product: "Runtime")]
        case .hero: return [.package(product: "Hero")]
        case .snapshottesting: return [.package(product: "SnapshotTesting")]
        case .shake: return [.package(product: "Shake")]
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
                .package(product: "DatadogStatic"),
                .package(product: "DatadogCrashReporting"),
            ]
        case .hAnalytics:
            return [
                .package(product: "hAnalytics")
            ]
        case .odysseyKit:
            return [
                .package(product: "OdysseyKit")
            ]
        case .authlib:
            return [
                .package(product: "authlib")
            ]
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
            packages: packages,
            settings: .settings(configurations: projectConfigurations),
            targets: [
                Target(
                    name: name,
                    platform: .iOS,
                    product: .framework,
                    bundleId: "com.hedvig.\(name)",
                    deploymentTarget: .iOS(targetVersion: "14.0", devices: [.iphone, .ipad]),
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
