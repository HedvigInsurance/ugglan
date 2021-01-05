import ProjectDescription

public enum FeatureTarget {
    case framework
    case frameworkResources
    case tests
    case example
    case testing
}

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

    public var isTestDependency: Bool {
        self == .runtime
    }

    public var isExcludedFromMainApps: Bool {
        self == .adyen
    }

    public func swiftPackages() -> [Package] {
        switch self {
        case .adyen:
            return [
                .package(url: "https://github.com/Adyen/adyen-ios", .upToNextMajor(from: "3.8.2")),
                .package(url: "https://github.com/HedvigInsurance/Runtime", .branch("master")),
                .package(url: "https://github.com/firebase/firebase-ios-sdk", .upToNextMajor(from: "7.3.1")),
            ]
        default:
            return []
        }
    }

    public func targetDependencies() -> [TargetDependency] {
        switch self {
        case .sentry:
            return [
                .xcFramework(path: "../../Carthage/Build/Sentry.xcframework"),
            ]
        case .adyen:
            return [
                .package(product: "Adyen"),
                .package(product: "AdyenCard"),
                .package(product: "AdyenDropIn"),
            ]
        case .firebase:
            return [
                .package(product: "FirebaseMessaging"),
            ]
        case .fb:
            return [
                .xcFramework(path: "../../Carthage/Build/FBSDKCoreKit.xcframework"),
            ]
        case .kingfisher:
            return [
                .xcFramework(path: "../../Carthage/Build/Kingfisher.xcframework"),
            ]
        case .apollo:
            return [
                .xcFramework(path: "../../Carthage/Build/Apollo.xcframework"),
                .xcFramework(path: "../../Carthage/Build/ApolloWebSocket.xcframework"),
                .xcFramework(path: "../../Carthage/Build/Starscream.xcframework"),
            ]
        case .flow:
            return [
                .xcFramework(path: "../../Carthage/Build/Flow.xcframework"),
            ]
        case .form:
            return [
                .xcFramework(path: "../../Carthage/Build/Form.xcframework"),
            ]
        case .presentation:
            return [
                .xcFramework(path: "../../Carthage/Build/Presentation.xcframework"),
            ]
        case .ease:
            return [
                .xcFramework(path: "../../Carthage/Build/Ease.xcframework"),
            ]
        case .dynamiccolor:
            return [
                .xcFramework(path: "../../Carthage/Build/DynamicColor.xcframework"),
            ]
        case .disk:
            return [
                .xcFramework(path: "../../Carthage/Build/Disk.xcframework"),
            ]
        case .snapkit:
            return [
                .xcFramework(path: "../../Carthage/Build/SnapKit.xcframework"),
            ]
        case .markdownkit:
            return [
                .xcFramework(path: "../../Carthage/Build/MarkdownKit.xcframework"),
            ]
        case .mixpanel:
            return [
                .xcFramework(path: "../../Carthage/Build/Mixpanel.xcframework"),
            ]
        case .runtime:
            return [
                .package(product: "Runtime"),
            ]
        case .hero:
            return [
                .xcFramework(path: "../../Carthage/Build/Hero.xcframework"),
            ]
        }
    }
}

public extension Project {
    static func framework(name: String,
                          targets: Set<FeatureTarget> = Set([
                              .framework,
                              .tests,
                              .example,
                              .testing,
                          ]),
                          externalDependencies: [ExternalDependencies] = [],
                          dependencies: [String] = [],
                          sdks: [String] = [],
                          includesGraphQL: Bool = false) -> Project
    {
        // Configurations
        let frameworkConfigurations: [CustomConfiguration] = [
            .debug(name: "Debug", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/iOS/iOS-Framework.xcconfig")),
            .release(name: "Release", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/iOS/iOS-Framework.xcconfig")),
        ]

        let testsConfigurations: [CustomConfiguration] = [
            .debug(name: "Debug", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig")),
            .release(name: "Release", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig")),
        ]
        let appConfigurations: [CustomConfiguration] = [
            .debug(name: "Debug", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")),
            .release(name: "Release", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")),
        ]
        let projectConfigurations: [CustomConfiguration] = [
            .debug(name: "Debug", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/Base/Configurations/Debug.xcconfig")),
            .release(name: "Release", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/Base/Configurations/Release.xcconfig")),
        ]

        // Test dependencies
        var testsDependencies: [TargetDependency] = [
            .target(name: "\(name)"),
            .project(target: "Testing", path: .relativeToRoot("Projects/Testing")),
            .xcFramework(path: "../../Carthage/Build/SnapshotTesting.xcframework"),
        ]
        dependencies.forEach { testsDependencies.append(.project(target: $0, path: .relativeToRoot("Projects/\($0)"))) }

        if targets.contains(.testing) {
            testsDependencies.append(.target(name: "\(name)Testing"))
        }

        // Target dependencies
        var targetDependencies: [TargetDependency] = dependencies.map { .project(target: $0, path: .relativeToRoot("Projects/\($0)")) }
        targetDependencies.append(contentsOf: sdks.map { .sdk(name: $0) })

        var targetDependenciesWithExternal: [TargetDependency] = [targetDependencies, externalDependencies.map { externalDependency in
            externalDependency.targetDependencies()
        }.flatMap { $0 }].flatMap { $0 }

        let hGraphQLName = "hGraphQL"

        if includesGraphQL, !dependencies.contains(hGraphQLName), name != hGraphQLName {
            targetDependencies.append(.project(target: hGraphQLName, path: .relativeToRoot("Projects/\(hGraphQLName)")))
            targetDependencies.append(contentsOf: ExternalDependencies.disk.targetDependencies())
        }

        let targetActions: [TargetAction] = []

        // Project targets
        var projectTargets: [Target] = []
        if targets.contains(.framework) {
            let sources: SourceFilesList = includesGraphQL ?
                ["Sources/**/*.swift", "GraphQL/**/*.swift"] :
                ["Sources/**/*.swift"]
            projectTargets.append(Target(name: name,
                                         platform: .iOS,
                                         product: .framework,
                                         bundleId: "com.hedvig.\(name)",
                                         deploymentTarget: .iOS(targetVersion: "12.0", devices: [.iphone, .ipad, .mac]),
                                         infoPlist: .default,
                                         sources: sources,
                                         resources: targets.contains(.frameworkResources) ? ["Resources/**"] : [],
                                         actions: targetActions,
                                         dependencies: targetDependenciesWithExternal,
                                         settings: Settings(base: [:], configurations: frameworkConfigurations)))
        }
        if targets.contains(.testing) {
            projectTargets.append(Target(name: "\(name)Testing",
                                         platform: .iOS,
                                         product: .framework,
                                         bundleId: "com.hedvig.\(name)Testing",
                                         deploymentTarget: .iOS(targetVersion: "12.0", devices: [.iphone, .ipad, .mac]),
                                         infoPlist: .default,
                                         sources: "Testing/**/*.swift",
                                         actions: targetActions,
                                         dependencies: [[.target(name: "\(name)"), .project(target: "TestingUtil", path: .relativeToRoot("Projects/TestingUtil"))], targetDependencies].flatMap { $0 },
                                         settings: Settings(base: [:], configurations: frameworkConfigurations)))
        }
        if targets.contains(.tests) {
            projectTargets.append(Target(name: "\(name)Tests",
                                         platform: .iOS,
                                         product: .unitTests,
                                         bundleId: "com.hedvig.\(name)Tests",
                                         deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad, .mac]),
                                         infoPlist: .default,
                                         sources: "Tests/**/*.swift",
                                         actions: targetActions,
                                         dependencies: [[.target(name: "\(name)Example"), .project(target: "TestingUtil", path: .relativeToRoot("Projects/TestingUtil"))], testsDependencies].flatMap { $0 },
                                         settings: Settings(base: [:], configurations: testsConfigurations)))
        }
        if targets.contains(.example) {
            projectTargets.append(Target(name: "\(name)Example",
                                         platform: .iOS,
                                         product: .app,
                                         bundleId: "com.hedvig.example.\(name)Example",
                                         deploymentTarget: .iOS(targetVersion: "12.0", devices: [.iphone, .ipad, .mac]),
                                         infoPlist: .extendingDefault(with: ["UIMainStoryboardFile": "", "UILaunchStoryboardName": "LaunchScreen"]),
                                         sources: ["Example/Sources/**/*.swift", "Sources/Derived/API.swift"],
                                         resources: "Example/Resources/**",
                                         actions: targetActions,
                                         dependencies: [[.target(name: "\(name)"), .project(target: "ExampleUtil", path: .relativeToRoot("Projects/ExampleUtil")), .project(target: "TestingUtil", path: .relativeToRoot("Projects/TestingUtil"))], targets.contains(.testing) ? [.target(name: "\(name)Testing")] : [], targetDependencies].flatMap { $0 },
                                         settings: Settings(base: ["PROVISIONING_PROFILE_SPECIFIER": "match Development com.hedvig.example.*"], configurations: appConfigurations)))
        }

        func getTestAction() -> TestAction {
            TestAction(
                targets: [TestableTarget(target: TargetReference(stringLiteral: "\(name)Tests"), parallelizable: true)],
                arguments: Arguments(environment: ["SNAPSHOT_ARTIFACTS": "/tmp/__SnapshotFailures__"],
                                     launchArguments: ["-UIPreferredContentSizeCategoryName": true, "UICTContentSizeCategoryM": true]),
                coverage: true
            )
        }

        var swiftPackages = externalDependencies.map { $0.swiftPackages() }.flatMap { $0 }

        // Project
        return Project(name: name,
                       organizationName: "Hedvig",
                       packages: swiftPackages,
                       settings: Settings(configurations: projectConfigurations),
                       targets: projectTargets,
                       schemes: [
                           Scheme(
                               name: name,
                               shared: true,
                               buildAction: BuildAction(targets: [TargetReference(stringLiteral: name)]),
                               testAction: targets.contains(.tests) ? getTestAction() : nil,
                               runAction: nil
                           ),
                           targets.contains(.example) ? Scheme(
                               name: "\(name)Example",
                               shared: true,
                               buildAction: BuildAction(targets: [TargetReference(stringLiteral: "\(name)Example")]),
                               testAction: getTestAction(),
                               runAction: RunAction(executable: TargetReference(stringLiteral: "\(name)Example"))
                           ) : nil,
                       ].compactMap { $0 },
                       additionalFiles: [
                           includesGraphQL ? .folderReference(path: "GraphQL") : nil,
                       ].compactMap { $0 })
    }
}
