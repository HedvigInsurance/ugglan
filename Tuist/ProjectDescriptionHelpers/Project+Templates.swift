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
    case flowfeedback
    case ease
    case dynamiccolor
    case disk
    case snapkit
    case markdownkit
    case mixpanel
    case runtime
    case sentry
    
    public var isTestDependency: Bool {
        return self == .runtime
    }

    public func targetDependencies() -> [TargetDependency] {
        switch self {
        case .sentry:
            return [
                .framework(path: "../../Carthage/Build/iOS/Sentry.framework")
            ]
        case .adyen:
            return [
                .framework(path: "../../Carthage/Build/iOS/Adyen.framework"),
                .framework(path: "../../Carthage/Build/iOS/Adyen3DS2.framework"),
                .framework(path: "../../Carthage/Build/iOS/AdyenCard.framework"),
                .framework(path: "../../Carthage/Build/iOS/AdyenDropIn.framework"),
            ]
        case .firebase:
            return [
                .framework(path: "../../Carthage/Build/iOS/GoogleUtilities.framework"),
                .framework(path: "../../Carthage/Build/iOS/Protobuf.framework"),
                .framework(path: "../../Carthage/Build/iOS/PromisesObjC.framework"),
                .framework(path: "../../Carthage/Build/iOS/FirebaseInstallations.framework"),
                .framework(path: "../../Carthage/Build/iOS/FirebaseMessaging.framework"),
                .framework(path: "../../Carthage/Build/iOS/FirebaseInstanceID.framework"),
                .framework(path: "../../Carthage/Build/iOS/FirebaseCore.framework"),
            ]
        case .fb:
            return [
                .framework(path: "../../Carthage/Build/iOS/FBSDKCoreKit.framework"),
            ]
        case .kingfisher:
            return [
                .framework(path: "../../Carthage/Build/iOS/Kingfisher.framework"),
            ]
        case .apollo:
            return [
                .framework(path: "../../Carthage/Build/iOS/Apollo.framework"),
                .framework(path: "../../Carthage/Build/iOS/ApolloWebSocket.framework"),
            ]
        case .flow:
            return [
                .framework(path: "../../Carthage/Build/iOS/Flow.framework"),
            ]
        case .form:
            return [
                .framework(path: "../../Carthage/Build/iOS/Form.framework"),
            ]
        case .presentation:
            return [
                .framework(path: "../../Carthage/Build/iOS/Presentation.framework"),
            ]
        case .flowfeedback:
            return [
                .framework(path: "../../Carthage/Build/iOS/FlowFeedback.framework"),
            ]
        case .ease:
            return [
                .framework(path: "../../Carthage/Build/iOS/Ease.framework"),
            ]
        case .dynamiccolor:
            return [
                .framework(path: "../../Carthage/Build/iOS/DynamicColor.framework"),
            ]
        case .disk:
            return [
                .framework(path: "../../Carthage/Build/iOS/Disk.framework"),
            ]
        case .snapkit:
            return [
                .framework(path: "../../Carthage/Build/iOS/SnapKit.framework"),
            ]
        case .markdownkit:
            return [
                .framework(path: "../../Carthage/Build/iOS/MarkdownKit.framework"),
            ]
        case .mixpanel:
            return [
                .framework(path: "../../Carthage/Build/iOS/Mixpanel.framework"),
            ]
        case .runtime:
            return [
                 .framework(path: "../../Carthage/Build/iOS/Runtime.framework"),
                 .framework(path: "../../Carthage/Build/iOS/CRuntime.framework"),
            ]
        }
    }
}

extension Project {
    public static func framework(name: String,
                                 targets: Set<FeatureTarget> = Set([
                                     .framework,
                                     .tests,
                                     .example,
                                     .testing,
                                 ]),
                                 externalDependencies: [ExternalDependencies] = [],
                                 dependencies: [String] = [],
                                 sdks: [String] = [],
                                 includesGraphQL: Bool = false) -> Project {
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
            .framework(path: "../../Carthage/Build/iOS/SnapshotTesting.framework"),
        ]
        dependencies.forEach { testsDependencies.append(.project(target: $0, path: .relativeToRoot("Projects/\($0)"))) }

        testsDependencies.append(contentsOf: externalDependencies.map { externalDependency in
            externalDependency.targetDependencies()
        }.flatMap { $0 })

        if targets.contains(.testing) {
            testsDependencies.append(.target(name: "\(name)Testing"))
        }

        // Target dependencies
        var targetDependencies: [TargetDependency] = dependencies.map { .project(target: $0, path: .relativeToRoot("Projects/\($0)")) }
        targetDependencies.append(contentsOf: sdks.map { .sdk(name: $0) })

        targetDependencies.append(contentsOf: externalDependencies.map { externalDependency in
            externalDependency.targetDependencies()
        }.flatMap { $0 })

        let targetActions: [TargetAction] = [
            .pre(path: "../../scripts/build_copy.sh", name: "Copy third party frameworks and applications"),
        ]

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
                                         deploymentTarget: .iOS(targetVersion: "12.0", devices: [.iphone, .ipad]),
                                         infoPlist: .default,
                                         sources: sources,
                                         resources: targets.contains(.frameworkResources) ? ["Resources/**"] : [],
                                         actions: targetActions,
                                         dependencies: targetDependencies,
                                         settings: Settings(base: [:], configurations: frameworkConfigurations)))
        }
        if targets.contains(.testing) {
            projectTargets.append(Target(name: "\(name)Testing",
                                         platform: .iOS,
                                         product: .framework,
                                         bundleId: "com.hedvig.\(name)Testing",
                                         deploymentTarget: .iOS(targetVersion: "12.0", devices: [.iphone, .ipad]),
                                         infoPlist: .default,
                                         sources: "Testing/**/*.swift",
                                         actions: targetActions,
                                         dependencies: [[.target(name: "\(name)")], targetDependencies].flatMap { $0 },
                                         settings: Settings(base: [:], configurations: frameworkConfigurations)))
        }
        if targets.contains(.tests) {
            projectTargets.append(Target(name: "\(name)Tests",
                                         platform: .iOS,
                                         product: .unitTests,
                                         bundleId: "com.hedvig.\(name)Tests",
                                         deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
                                         infoPlist: .default,
                                         sources: "Tests/**/*.swift",
                                         actions: targetActions,
                                         dependencies: [[.target(name: "\(name)Example")], testsDependencies].flatMap { $0 },
                                         settings: Settings(base: [:], configurations: testsConfigurations)))
        }
        if targets.contains(.example) {
            projectTargets.append(Target(name: "\(name)Example",
                                         platform: .iOS,
                                         product: .app,
                                         bundleId: "com.hedvig.\(name)Example",
                                         deploymentTarget: .iOS(targetVersion: "12.0", devices: [.iphone, .ipad]),
                                         infoPlist: .extendingDefault(with: ["UIMainStoryboardFile": "", "UILaunchStoryboardName": "LaunchScreen"]),
                                         sources: ["Example/Sources/**/*.swift", "Sources/Derived/API.swift"],
                                         resources: "Example/Resources/**",
                                         actions: targetActions,
                                         dependencies: [[.target(name: "\(name)"), .project(target: "ExampleUtil", path: .relativeToRoot("Projects/ExampleUtil"))], targets.contains(.testing) ? [.target(name: "\(name)Testing")] : [], targetDependencies].flatMap { $0 },
                                         settings: Settings(base: [:], configurations: appConfigurations)))
        }

        func getTestAction(_ recordMode: Bool) -> TestAction {
            TestAction(
                targets: [TestableTarget(target: TargetReference(stringLiteral: "\(name)Tests"), parallelizable: true)],
                arguments: Arguments(environment: ["SNAPSHOT_ARTIFACTS": "/tmp/__SnapshotFailures__", "SNAPSHOT_TEST_MODE": recordMode ? "RECORD" : ""],
                                     launch: ["-UIPreferredContentSizeCategoryName": true, "UICTContentSizeCategoryM": true]),
                coverage: true
            )
        }

        // Project
        return Project(name: name,
                       organizationName: "Hedvig",
                       packages: [],
                       settings: Settings(configurations: projectConfigurations),
                       targets: projectTargets,
                       schemes: [
                           Scheme(
                               name: name,
                               shared: true,
                               buildAction: BuildAction(targets: [TargetReference(stringLiteral: name)]),
                               testAction: targets.contains(.tests) ? getTestAction(false) : nil,
                               runAction: nil
                           ),
                           targets.contains(.tests) ? Scheme(
                               name: "\(name)Tests Record",
                               shared: true,
                               buildAction: nil,
                               testAction: getTestAction(true),
                               runAction: nil
                           ) : nil,
                           targets.contains(.example) ? Scheme(
                               name: "\(name)Example",
                               shared: true,
                               buildAction: BuildAction(targets: [TargetReference(stringLiteral: "\(name)Example")]),
                               testAction: getTestAction(false),
                               runAction: RunAction(executable: TargetReference(stringLiteral: "\(name)Example"))
                           ) : nil,
                       ].compactMap { $0 },
                       additionalFiles: [
                           includesGraphQL ? .folderReference(path: "GraphQL") : nil,
                       ].compactMap { $0 })
    }
}
