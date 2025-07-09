import Foundation
import ProjectDescription

public enum FeatureTarget {
    case framework
    case frameworkResources
    case tests
    case example
    case testing
}

extension Project {
    public static func framework(
        name: String,
        targets: Set<FeatureTarget> = Set([.framework, .tests, .example, .testing]),
        projects: [String] = [],
        dependencies: [String] = ["CoreDependencies"],
        sdks: [String] = []
    ) -> Project {

        let settings: [String: SettingValue] = {
            ["SWIFT_VERSION": "6.0.2"]
        }()
        let frameworkConfigurations: [Configuration] = [
            .debug(
                name: "Debug",
                settings: settings,
                xcconfig: .relativeToRoot("Configurations/iOS/iOS-Framework-Debug.xcconfig")
            ),
            .release(
                name: "Release",
                settings: settings,
                xcconfig: .relativeToRoot("Configurations/iOS/iOS-Framework-Release.xcconfig")
            ),
        ]

        let testsConfigurations: [Configuration] = [
            .debug(
                name: "Debug",
                settings: settings,
                xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig")
            ),
            .release(
                name: "Release",
                settings: settings,
                xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig")
            ),
        ]
        let appConfigurations: [Configuration] = [
            .debug(
                name: "Debug",
                settings: settings,
                xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")
            ),
            .release(
                name: "Release",
                settings: settings,
                xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")
            ),
        ]
        let projectConfigurations: [Configuration] = [
            .debug(
                name: "Debug",
                settings: settings,
                xcconfig: .relativeToRoot("Configurations/Base/Configurations/Debug.xcconfig")
            ),
            .release(
                name: "Release",
                settings: settings,
                xcconfig: .relativeToRoot("Configurations/Base/Configurations/Release.xcconfig")
            ),
        ]

        var testsDependencies: [TargetDependency] = [
            .target(name: "\(name)")
            //            .project(target: "Testing", path: .relativeToRoot("Projects/Testing")),
        ]
        projects.forEach {
            testsDependencies.append(.project(target: $0, path: .relativeToRoot("Projects/\($0)")))
        }

        if targets.contains(.testing) { testsDependencies.append(.target(name: "\(name)Testing")) }

        var targetDependencies: [TargetDependency] = projects.map {
            .project(target: $0, path: .relativeToRoot("Projects/\($0)"))
        }
        targetDependencies.append(contentsOf: sdks.map { .sdk(name: $0, type: .framework) })
        targetDependencies.append(
            contentsOf: dependencies.map {
                .project(target: $0, path: .relativeToRoot("Dependencies/\($0)"))
            }
        )

        var projectTargets: [Target] = []

        if targets.contains(.framework) {
            let sources: SourceFilesList = "Sources/**/*.swift"
            let frameworkTarget = Target.target(
                name: name,
                destinations: .iOS,
                product: .framework,
                bundleId: "com.hedvig.\(name)",
                deploymentTargets: .iOS("15.0"),
                infoPlist: .default,
                sources: sources,
                resources: targets.contains(.frameworkResources) ? ["Resources/**"] : [],
                dependencies: targetDependencies,
                settings: .settings(base: [:], configurations: frameworkConfigurations)
            )

            projectTargets.append(frameworkTarget)
        }

        if targets.contains(.testing) {
            let testingTarget = Target.target(
                name: "\(name)Testing",
                destinations: .iOS,
                product: .framework,
                bundleId: "com.hedvig.\(name)Testing",
                deploymentTargets: .iOS("15.0"),
                infoPlist: .default,
                sources: "Testing/**/*.swift",
                dependencies: [
                    [
                        .target(name: "\(name)"),
                        .project(
                            target: "DevDependencies",
                            path: .relativeToRoot("Dependencies/DevDependencies")
                        ),
                    ], targetDependencies,
                ]
                .flatMap { $0 },
                settings: .settings(base: [:], configurations: frameworkConfigurations)
            )

            projectTargets.append(testingTarget)
        }

        if targets.contains(.tests) {
            let testTarget = Target.target(
                name: "\(name)Tests",
                destinations: .iOS,
                product: .unitTests,
                bundleId: "com.hedvig.\(name)Tests",
                deploymentTargets: .iOS("15.0"),
                infoPlist: .default,
                sources: "Tests/**/*.swift",
                dependencies: [
                    [
                        .target(name: "\(name)Example"),
                        .project(
                            target: "CoreDependencies",
                            path: .relativeToRoot("Dependencies/CoreDependencies")
                        ),
                        .project(
                            target: "TestDependencies",
                            path: .relativeToRoot("Dependencies/TestDependencies")
                        ),
                    ], testsDependencies,
                ]
                .flatMap { $0 },
                settings: .settings(base: [:], configurations: testsConfigurations)
            )

            projectTargets.append(testTarget)
        }

        if targets.contains(.example) {
            let exampleTarget = Target.target(
                name: "\(name)Example",
                destinations: .iOS,
                product: .app,
                bundleId: "com.hedvig.example.\(name)Example",
                deploymentTargets: .iOS("15.0"),
                infoPlist: .extendingDefault(with: [
                    "UIMainStoryboardFile": "",
                    "NSMicrophoneUsageDescription": "Hedvig uses the microphone to let you record messages and videos.",
                    "UILaunchStoryboardName": "LaunchScreen",
                    "UIApplicationSceneManifest": [
                        "UIApplicationSupportsMultipleScenes": true,
                        "UISceneConfigurations": [
                            "UIWindowSceneSessionRoleApplication": [
                                [
                                    "UISceneConfigurationName":
                                        "Default Configuration",
                                    "UISceneDelegateClassName":
                                        "\(name)Example.SceneDelegate",
                                ]
                            ]
                        ],
                    ],
                ]),
                sources: ["Example/Sources/**/*.swift", "Sources/Derived/API.swift"],
                resources: "Example/Resources/**",
                scripts: [
                    .post(
                        path: "../../scripts/post-build-action.sh",
                        arguments: [],
                        name: "Clean frameworks"
                    )
                ],
                dependencies: [
                    [
                        .target(name: "\(name)"),
                        .project(
                            target: "DevDependencies",
                            path: .relativeToRoot("Dependencies/DevDependencies")
                        ),
                    ], targets.contains(.testing) ? [.target(name: "\(name)Testing")] : [],
                    targetDependencies,
                ]
                .flatMap { $0 },
                settings: .settings(
                    base: [
                        "PROVISIONING_PROFILE_SPECIFIER":
                            "match Development com.hedvig.example.*"
                    ],
                    configurations: appConfigurations
                )
            )

            projectTargets.append(exampleTarget)
        }

        func getTestAction() -> TestAction {
            TestAction.targets(
                [
                    TestableTarget.testableTarget(
                        target: TargetReference(stringLiteral: "\(name)Tests"),
                        isParallelizable: false
                    )
                ],
                arguments: Arguments.arguments(
                    environmentVariables: [
                        "SNAPSHOT_ARTIFACTS": .environmentVariable(
                            value: "/tmp/\(UUID().uuidString)/__SnapshotFailures__",
                            isEnabled: true
                        )
                    ]
                ),
                options: .options(coverage: true, codeCoverageTargets: ["\(name)"])
            )
        }
        return Project(
            name: name,
            organizationName: "Hedvig",
            options: .options(
                disableBundleAccessors: true,
                disableSynthesizedResourceAccessors: true
            ),
            packages: [],
            settings: .settings(configurations: projectConfigurations),
            targets: projectTargets,
            schemes: [
                Scheme.scheme(
                    name: name,
                    shared: true,
                    buildAction: BuildAction.buildAction(targets: [TargetReference(stringLiteral: name)]),
                    testAction: targets.contains(.tests) ? getTestAction() : nil,
                    runAction: nil
                ),
                targets.contains(.example)
                    ? Scheme.scheme(
                        name: "\(name)Example",
                        shared: true,
                        buildAction: BuildAction.buildAction(targets: [
                            TargetReference(stringLiteral: "\(name)Example")
                        ]),
                        testAction: getTestAction(),
                        runAction: .runAction(executable: TargetReference(stringLiteral: "\(name)Example"))
                    ) : nil,
            ]
            .compactMap { $0 },
            additionalFiles: name == "hGraphQL" ? [.folderReference(path: "GraphQL")] : []
        )
    }
}
