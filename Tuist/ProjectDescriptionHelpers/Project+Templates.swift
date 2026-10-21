import Foundation
import ProjectDescription

public enum FeatureTarget {
    case framework
    case frameworkResources
    case tests
    case example
}

extension Project {
    public static func framework(
        name: String,
        targets: Set<FeatureTarget> = Set([.framework, .tests, .example]),
        projects: [String] = [],
        dependencies: [String] = ["CoreDependencies"],
        sdks: [String] = []
    ) -> Project {
        let settings: [String: SettingValue] = ["SWIFT_VERSION": swiftVersion]
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
        ]
        for item in projects {
            testsDependencies.append(.project(target: item, path: .relativeToRoot("Projects/\(item)")))
        }

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
            let frameworkTarget = Target.target(
                name: name,
                destinations: .iOS,
                product: .framework,
                bundleId: "com.hedvig.\(name)",
                deploymentTargets: .iOS("17.0"),
                infoPlist: .default,
                resources: targets.contains(.frameworkResources) ? ["Resources/**"] : [],
                buildableFolders: ["Sources"],
                dependencies: targetDependencies,
                settings: .settings(base: [:], configurations: frameworkConfigurations)
            )

            projectTargets.append(frameworkTarget)
        }

        if targets.contains(.tests) {
            let testTarget = Target.target(
                name: "\(name)Tests",
                destinations: .iOS,
                product: .unitTests,
                bundleId: "com.hedvig.\(name)Tests",
                deploymentTargets: .iOS("17.0"),
                infoPlist: .default,
                buildableFolders: ["Tests"],
                dependencies: [
                    // Hosted in the module's example app where there is one. Modules that only ship
                    // a framework get a plain logic-test bundle instead, rather than being forced to
                    // carry an example app to have tests; testsDependencies already links the
                    // framework itself, so nothing is added here in that case.
                    targets.contains(.example) ? [.target(name: "\(name)Example")] : [],
                    [
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
                deploymentTargets: .iOS("17.0"),
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
                // Same post-build step as the main app: embeds RiveRuntime (which Tuist doesn't embed) and
                // fixes up the bundle. Without it, examples linking SubmitClaimChat crash on launch in dyld,
                // so the app and its SwiftUI previews never start.
                scripts: [
                    .post(
                        path: .relativeToRoot("scripts/post-build-action.sh"),
                        arguments: [],
                        name: "Clean frameworks",
                        basedOnDependencyAnalysis: false
                    )
                ],
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
                settings: .settings(
                    base: [
                        "PROVISIONING_PROFILE_SPECIFIER":
                            "match Development com.hedvig.example.*",
                        "CODE_SIGN_STYLE": "automatic",

                    ],
                    configurations: appConfigurations,
                    defaultSettings: .app
                )
            )

            projectTargets.append(exampleTarget)
        }

        func getTestAction() -> TestAction {
            TestAction.targets(
                [
                    TestableTarget.testableTarget(
                        target: TargetReference(stringLiteral: "\(name)Tests"),
                        parallelization: .enabled
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
