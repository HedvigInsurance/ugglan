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
    case mixpanel
    case runtime
    case hero
    case snapshottesting
    case shake
    case reveal
    case datadog

    public var isTestDependency: Bool { self == .snapshottesting }

    public var isDevDependency: Bool { false }

    public var isResourceBundledDependency: Bool { self == .mixpanel || self == .adyen }

    public var isAppDependency: Bool { self == .firebase || self == .datadog }

    public var isCoreDependency: Bool {
        !isTestDependency && !isDevDependency && !isResourceBundledDependency && !isAppDependency
    }

    public func swiftPackages() -> [Package] {
        switch self {
        case .adyen: return [.package(url: "https://github.com/Adyen/adyen-ios", .exact(from: "4.2.0"))]
        case .runtime:
            return [.package(url: "https://github.com/wickwirew/Runtime", .exact("2.2.2"))]
        case .firebase:
            return [
                .package(
                    url: "https://github.com/firebase/firebase-ios-sdk",
                    .upToNextMajor(from: "7.3.1")
                )
            ]
        case .apollo: return [.package(url: "https://github.com/apollographql/apollo-ios", .exact("0.41.0"))]
        case .flow:
            return [.package(url: "https://github.com/HedvigInsurance/Flow", .upToNextMajor(from: "1.8.7"))]
        case .form:
            return [
                .package(
                    url: "https://github.com/HedvigInsurance/Form",
                    .exact("3.0.8")
                )
            ]
        case .presentation:
            return [
                .package(
                    url: "https://github.com/HedvigInsurance/Presentation",
                    .upToNextMajor(from: "2.0.14")
                )
            ]
        case .dynamiccolor:
            return [
                .package(url: "https://github.com/yannickl/DynamicColor", .upToNextMajor(from: "5.0.1"))
            ]
        case .disk:
            return [.package(url: "https://github.com/HedvigInsurance/Disk", .upToNextMajor(from: "0.6.4"))]
        case .kingfisher:
            return [.package(url: "https://github.com/onevcat/Kingfisher", .upToNextMajor(from: "7.0.0"))]
        case .snapkit:
            return [.package(url: "https://github.com/SnapKit/SnapKit", .upToNextMajor(from: "5.0.1"))]
        case .markdownkit:
            return [
                .package(
                    url: "https://github.com/bmoliveira/MarkdownKit",
                    .upToNextMajor(from: "1.7.1")
                )
            ]
        case .mixpanel:
            return [
                .package(
                    url: "https://github.com/mixpanel/mixpanel-swift",
                    .upToNextMajor(from: "2.8.1")
                )
            ]
        case .hero: return [.package(url: "https://github.com/HeroTransitions/Hero", .exact("1.5.0"))]
        case .snapshottesting:
            return [
                .package(
                    url: "https://github.com/pointfreeco/swift-snapshot-testing",
                    .upToNextMajor(from: "1.8.2")
                )
            ]
        case .shake: return [.package(url: "https://github.com/shakebugs/shake-ios", .exact("14.1.5"))]
        case .reveal: return []
        case .datadog:
            return [.package(url: "https://github.com/DataDog/dd-sdk-ios.git", .upToNextMajor(from: "1.7.0-beta3"))]
        }
    }

    public func targetDependencies() -> [TargetDependency] {
        switch self {
        case .adyen:
            return [
                .package(product: "Adyen"), .package(product: "AdyenCard"),
                .package(product: "AdyenDropIn"),
            ]
        case .firebase: return [.package(product: "FirebaseAnalytics"), .package(product: "FirebaseMessaging")]
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
        case .mixpanel: return [.package(product: "Mixpanel")]
        case .runtime: return [.package(product: "Runtime")]
        case .hero: return [.package(product: "Hero")]
        case .snapshottesting: return [.package(product: "SnapshotTesting")]
        case .shake: return [.package(product: "Shake")]
        case .reveal:
            let path = Path(
                "\(FileManager.default.homeDirectoryForCurrentUser.path)/Library/Application Support/Reveal/RevealServer/RevealServer.xcframework"
            )

            guard FileManager.default.fileExists(atPath: path.pathString) else {
                return []
            }

            return [
                .xcFramework(
                    path: path
                )
            ]
        case .datadog:
            return [
                .package(product: "DatadogStatic"),
                .package(product: "DatadogCrashReporting"),
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
        let frameworkConfigurations: [CustomConfiguration] = [
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

        let projectConfigurations: [CustomConfiguration] = [
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
                .flatMap { $0 }, sdks.map { sdk in .sdk(name: sdk) },
        ]
        .flatMap { $0 }

        let packages = externalDependencies.map { externalDependency in externalDependency.swiftPackages() }
            .flatMap { $0 }

        return Project(
            name: name,
            organizationName: "Hedvig",
            packages: packages,
            settings: Settings(configurations: projectConfigurations),
            targets: [
                Target(
                    name: name,
                    platform: .iOS,
                    product: .framework,
                    bundleId: "com.hedvig.\(name)",
                    deploymentTarget: .iOS(targetVersion: "12.0", devices: [.iphone, .ipad, .mac]),
                    infoPlist: .default,
                    sources: ["Sources/**/*.swift"],
                    resources: [],
                    actions: [],
                    dependencies: dependencies,
                    settings: Settings(base: [:], configurations: frameworkConfigurations)
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
