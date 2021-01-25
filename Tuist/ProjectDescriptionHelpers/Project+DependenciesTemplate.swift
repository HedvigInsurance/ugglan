import ProjectDescription

public enum ExternalDependencies: CaseIterable {
    case adyen
    case firebase
    case fb
    case kingfisher
    case apollo
    case flow
    case form
    case presentation
    case ease
    case dynamiccolor
    case disk
    case snapkit
    case markdownkit
    case mixpanel
    case runtime
    case sentry
    case hero
    case snapshottesting

    public var isTestDependency: Bool {
        self == .snapshottesting
    }

    public var isDevDependency: Bool {
        self == .runtime
    }

    public var isResourceBundledDependency: Bool {
        self == .mixpanel || self == .adyen
    }

    public var isCoreDependency: Bool {
        !isTestDependency && !isDevDependency && !isResourceBundledDependency
    }

    public func swiftPackages() -> [Package] {
        switch self {
        case .adyen:
            return [
                .package(url: "https://github.com/Adyen/adyen-ios", .upToNextMajor(from: "3.8.2")),
            ]
        case .runtime:
            return [
                .package(url: "https://github.com/wickwirew/Runtime", .upToNextMajor(from: "2.2.2")),
            ]
        case .firebase:
            return [
                .package(url: "https://github.com/firebase/firebase-ios-sdk", .upToNextMajor(from: "7.3.1")),
            ]
        case .apollo:
            return [
                .package(url: "https://github.com/apollographql/apollo-ios", .upToNextMajor(from: "0.39.0")),
            ]
        case .flow:
            return [
                .package(url: "https://github.com/HedvigInsurance/Flow", .branch("master")),
            ]
        case .form:
            return [
                .package(url: "https://github.com/HedvigInsurance/Form", .branch("master")),
            ]
        case .presentation:
            return [
                .package(url: "https://github.com/HedvigInsurance/Presentation", .branch("master")),
            ]
        case .ease:
            return [
                .package(url: "https://github.com/HedvigInsurance/Ease", .branch("master")),
            ]
        case .dynamiccolor:
            return [
                .package(url: "https://github.com/yannickl/DynamicColor", .upToNextMajor(from: "5.0.1")),
            ]
        case .disk:
            return [
                .package(url: "https://github.com/HedvigInsurance/Disk", .upToNextMajor(from: "0.6.4")),
            ]
        case .kingfisher:
            return [
                .package(url: "https://github.com/onevcat/Kingfisher", .upToNextMajor(from: "6.0.1")),
            ]
        case .fb:
            return [
                .package(url: "https://github.com/facebook/facebook-ios-sdk", .upToNextMajor(from: "8.2.0")),
            ]
        case .snapkit:
            return [
                .package(url: "https://github.com/SnapKit/SnapKit", .upToNextMajor(from: "5.0.1")),
            ]
        case .markdownkit:
            return [
                .package(url: "https://github.com/HedvigInsurance/MarkdownKit", .branch("master")),
            ]
        case .mixpanel:
            return [
                .package(url: "https://github.com/mixpanel/mixpanel-swift", .upToNextMajor(from: "2.8.1")),
            ]
        case .hero:
            return [
                .package(url: "https://github.com/HeroTransitions/Hero", .upToNextMajor(from: "1.5.0")),
            ]
        case .sentry:
            return [
                .package(url: "https://github.com/getsentry/sentry-cocoa", .upToNextMajor(from: "6.0.12")),
            ]
        case .snapshottesting:
            return [
                .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", .upToNextMajor(from: "1.8.2")),
            ]
        }
    }

    public func targetDependencies() -> [TargetDependency] {
        switch self {
        case .sentry:
            return [
                .package(product: "Sentry"),
            ]
        case .adyen:
            return [
                .package(product: "Adyen"),
                .package(product: "AdyenCard"),
                .package(product: "AdyenDropIn"),
            ]
        case .firebase:
            return [
                .package(product: "FirebaseAnalytics"),
                .package(product: "FirebaseMessaging"),
            ]
        case .fb:
            return [
                .package(product: "FacebookCore"),
            ]
        case .kingfisher:
            return [
                .package(product: "Kingfisher"),
            ]
        case .apollo:
            return [
                .package(product: "ApolloWebSocket"),
                .package(product: "Apollo"),
            ]
        case .flow:
            return [
                .package(product: "Flow"),
            ]
        case .form:
            return [
                .package(product: "Form"),
            ]
        case .presentation:
            return [
                .package(product: "Presentation"),
            ]
        case .ease:
            return [
                .package(product: "Ease"),
            ]
        case .dynamiccolor:
            return [
                .package(product: "DynamicColor"),
            ]
        case .disk:
            return [
                .package(product: "Disk"),
            ]
        case .snapkit:
            return [
                .package(product: "SnapKit"),
            ]
        case .markdownkit:
            return [
                .package(product: "MarkdownKit"),
            ]
        case .mixpanel:
            return [
                .package(product: "Mixpanel"),
            ]
        case .runtime:
            return [
                .package(product: "Runtime"),
            ]
        case .hero:
            return [
                .package(product: "Hero"),
            ]
        case .snapshottesting:
            return [
                .package(product: "SnapshotTesting"),
            ]
        }
    }
}

public extension Project {
    static func dependenciesFramework(
        name: String,
        externalDependencies: [ExternalDependencies],
        sdks: [String] = []
    ) -> Project {
        let frameworkConfigurations: [CustomConfiguration] = [
            .debug(name: "Debug", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/iOS/iOS-Framework.xcconfig")),
            .release(name: "Release", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/iOS/iOS-Framework.xcconfig")),
        ]

        let projectConfigurations: [CustomConfiguration] = [
            .debug(name: "Debug", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/Base/Configurations/Debug.xcconfig")),
            .release(name: "Release", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/Base/Configurations/Release.xcconfig")),
        ]

        let dependencies: [TargetDependency] = [
            externalDependencies.map { externalDependency in
                externalDependency.targetDependencies()
            }.flatMap { $0 },
            sdks.map { sdk in
                .sdk(name: sdk)
            },
        ].flatMap { $0 }

        let packages = externalDependencies.map { externalDependency in
            externalDependency.swiftPackages()
        }.flatMap { $0 }

        return Project(
            name: name,
            organizationName: "Hedvig",
            packages: packages,
            settings: Settings(configurations: projectConfigurations),
            targets: [
                Target(name: name,
                       platform: .iOS,
                       product: .framework,
                       bundleId: "com.hedvig.\(name)",
                       deploymentTarget: .iOS(targetVersion: "12.0", devices: [.iphone, .ipad, .mac]),
                       infoPlist: .default,
                       sources: ["Sources/**/*.swift"],
                       resources: [],
                       actions: [
                           .post(
                               path: "../../scripts/post-build-action.sh",
                               arguments: [],
                               name: "Clean frameworks"
                           ),
                       ],
                       dependencies: dependencies,
                       settings: Settings(base: [:], configurations: frameworkConfigurations)),
            ],
            schemes: [
                Scheme(
                    name: name,
                    shared: true,
                    buildAction: BuildAction(targets: [TargetReference(stringLiteral: name)]),
                    testAction: nil,
                    runAction: nil
                ),
            ]
        )
    }
}
