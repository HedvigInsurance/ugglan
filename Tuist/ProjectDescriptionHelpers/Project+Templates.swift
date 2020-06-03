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
    case uicollectionview_animatedscroll
    case ease
    case dynamiccolor
    case disk
    case snapkit
    case markdownkit
    case mixpanel

    public func targetDependencies() -> [TargetDependency] {
        switch self {
        case .adyen:
            return [
                .framework(path: "../../Carthage/Build/iOS/Adyen.framework"),
                .framework(path: "../../Carthage/Build/iOS/Adyen3DS2.framework"),
                .framework(path: "../../Carthage/Build/iOS/AdyenCard.framework"),
                .framework(path: "../../Carthage/Build/iOS/AdyenDropIn.framework"),
            ]
        case .firebase:
            return [
                .framework(path: "../../Carthage/Build/iOS/FirebaseCrashlytics.framework"),
                .framework(path: "../../Carthage/Build/iOS/GoogleUtilities.framework"),
                .framework(path: "../../Carthage/Build/iOS/GoogleAppMeasurement.framework"),
                .framework(path: "../../Carthage/Build/iOS/Protobuf.framework"),
                .framework(path: "../../Carthage/Build/iOS/BoringSSL-GRPC.framework"),
                .framework(path: "../../Carthage/Build/iOS/leveldb-library.framework"),
                .framework(path: "../../Carthage/Build/iOS/gRPC-Core.framework"),
                .framework(path: "../../Carthage/Build/iOS/gRPC-C++.framework"),
                .framework(path: "../../Carthage/Build/iOS/PromisesObjC.framework"),
                .framework(path: "../../Carthage/Build/iOS/FirebaseInstallations.framework"),
                .framework(path: "../../Carthage/Build/iOS/FirebaseMessaging.framework"),
                .framework(path: "../../Carthage/Build/iOS/FirebaseFirestore.framework"),
                .framework(path: "../../Carthage/Build/iOS/FirebaseABTesting.framework"),
                .framework(path: "../../Carthage/Build/iOS/FirebaseInstanceID.framework"),
                .framework(path: "../../Carthage/Build/iOS/FirebaseDynamicLinks.framework"),
                .framework(path: "../../Carthage/Build/iOS/FirebaseAnalytics.framework"),
                .framework(path: "../../Carthage/Build/iOS/FirebaseCore.framework"),
                .framework(path: "../../Carthage/Build/iOS/abseil.framework"),
                .framework(path: "../../Carthage/Build/iOS/nanopb.framework"),
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
        case .uicollectionview_animatedscroll:
            return [
                .framework(path: "../../Carthage/Build/iOS/UICollectionView_AnimatedScroll.framework"),
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
            .debug(name: "Release", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/iOS/iOS-Framework.xcconfig")),
        ]
        let testsConfigurations: [CustomConfiguration] = [
            .debug(name: "Debug", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig")),
            .debug(name: "Release", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig")),
        ]
        let appConfigurations: [CustomConfiguration] = [
            .debug(name: "Debug", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")),
            .debug(name: "Release", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")),
        ]
        let projectConfigurations: [CustomConfiguration] = [
            .debug(name: "Debug", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/Base/Configurations/Debug.xcconfig")),
            .debug(name: "Release", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/Base/Configurations/Release.xcconfig")),
        ]

        // Test dependencies
        var testsDependencies: [TargetDependency] = [
            .target(name: "\(name)"),
            .project(target: "Testing", path: .relativeToRoot("Projects/Testing")),
            .framework(path: "../../Carthage/Build/iOS/SnapshotTesting.framework"),
        ]
        dependencies.forEach { testsDependencies.append(.project(target: "\($0)Testing", path: .relativeToRoot("Projects/\($0)"))) }

        testsDependencies.append(contentsOf: externalDependencies.map { externalDependency in
            externalDependency.targetDependencies()
        }.flatMap { $0 })

        // Target dependencies
        var targetDependencies: [TargetDependency] = dependencies.map { .project(target: $0, path: .relativeToRoot("Projects/\($0)")) }
        targetDependencies.append(contentsOf: sdks.map { .sdk(name: $0) })

        targetDependencies.append(contentsOf: externalDependencies.map { externalDependency in
            externalDependency.targetDependencies()
        }.flatMap { $0 })

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
                                         dependencies: targetDependencies,
                                         settings: Settings(configurations: frameworkConfigurations)))
        }
        if targets.contains(.testing) {
            projectTargets.append(Target(name: "\(name)Testing",
                                         platform: .iOS,
                                         product: .framework,
                                         bundleId: "com.hedvig.\(name)Testing",
                                         infoPlist: .default,
                                         sources: "Testing/**/*.swift",
                                         dependencies: [.target(name: "\(name)")],
                                         settings: Settings(configurations: frameworkConfigurations)))
        }
        if targets.contains(.tests) {
            projectTargets.append(Target(name: "\(name)Tests",
                                         platform: .iOS,
                                         product: .unitTests,
                                         bundleId: "com.hedvig.\(name)Tests",
                                         infoPlist: .default,
                                         sources: "Tests/**/*.swift",
                                         dependencies: testsDependencies,
                                         settings: Settings(configurations: testsConfigurations)))
        }
        if targets.contains(.example) {
            projectTargets.append(Target(name: "\(name)Example",
                                         platform: .iOS,
                                         product: .app,
                                         bundleId: "com.hedvig.\(name)Example",
                                         infoPlist: .extendingDefault(with: ["UIMainStoryboardFile": ""]),
                                         sources: "Example/Sources/**/*.swift",
                                         resources: "Example/Resources/**",
                                         dependencies: [[.target(name: "\(name)")], targetDependencies].flatMap { $0 },
                                         settings: Settings(configurations: appConfigurations)))
        }

        // Project
        return Project(name: name,
                       organizationName: "Hedvig",
                       settings: Settings(configurations: projectConfigurations),
                       targets: projectTargets,
                       schemes: [
                           Scheme(
                               name: name,
                               shared: true,
                               buildAction: BuildAction(targets: [TargetReference(stringLiteral: name)]),
                               testAction: targets.contains(.tests) ? TestAction(targets: [TestableTarget(target: TargetReference(stringLiteral: "\(name)Tests"), parallelizable: true)], arguments: Arguments(environment: ["SNAPSHOT_ARTIFACTS": "/tmp/__SnapshotFailures__"], launch: ["-UIPreferredContentSizeCategoryName": true, "UICTContentSizeCategoryM": true])) : nil,
                               runAction: nil
                           ),
                           targets.contains(.example) ? Scheme(
                               name: "\(name)Example",
                               shared: true,
                               buildAction: BuildAction(targets: [TargetReference(stringLiteral: "\(name)Example")]),
                               testAction: TestAction(targets: [TestableTarget(target: TargetReference(stringLiteral: "\(name)Tests"), parallelizable: true)], arguments: Arguments(environment: ["SNAPSHOT_ARTIFACTS": "/tmp/__SnapshotFailures__"], launch: ["-UIPreferredContentSizeCategoryName": true, "UICTContentSizeCategoryM": true])),
                               runAction: RunAction(executable: TargetReference(stringLiteral: "\(name)Example"))
                           ) : nil,
                       ].compactMap { $0 },
                       additionalFiles: [
                           includesGraphQL ? .folderReference(path: "GraphQL") : nil,
                       ].compactMap { $0 })
    }
}
