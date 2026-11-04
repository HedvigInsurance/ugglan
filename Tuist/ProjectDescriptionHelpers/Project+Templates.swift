import Foundation
import ProjectDescription

public enum FeatureTarget {
    case framework
    case frameworkResources
    case tests
    /// Hosts the tests in a minimal app (sources in the module's `TestHost/` folder), for tests that need a
    /// running UIApplication and window scene. Without it the tests are a plain logic-test bundle.
    case testHost
}

extension Project {
    public static func framework(
        name: String,
        targets: Set<FeatureTarget> = Set([.framework, .tests]),
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

        var projectTargets: [Target] = []

        if targets.contains(.framework) {
            let frameworkTarget = Target.target(
                name: name,
                destinations: .iOS,
                product: .framework,
                bundleId: "com.hedvig.\(name)",
                deploymentTargets: .iOS("17.0"),
                infoPlist: nil,
                resources: targets.contains(.frameworkResources) ? ["Resources/**"] : [],
                buildableFolders: ["Sources"],
                dependencies: targetDependencies,
                settings: .settings(base: .generatedInfoPlist, configurations: frameworkConfigurations)
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
                infoPlist: nil,
                buildableFolders: ["Tests"],
                // Hosted in the test host app where there is one, otherwise a plain logic-test bundle;
                // testsDependencies links the framework itself either way
                dependencies: [
                    targets.contains(.testHost) ? [.target(name: "\(name)TestHost")] : [],
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
                settings: .settings(base: .generatedInfoPlist, configurations: testsConfigurations)
            )

            projectTargets.append(testTarget)
        }

        if targets.contains(.testHost) {
            let testHostTarget = Target.target(
                name: "\(name)TestHost",
                destinations: .iOS,
                product: .app,
                bundleId: "com.hedvig.\(name)TestHost",
                deploymentTargets: .iOS("17.0"),
                infoPlist: nil,
                buildableFolders: ["TestHost"],
                // Same post-build step as the main app: embeds RiveRuntime (which Tuist doesn't embed) and fixes up
                // the bundle. Without it, a host linking SubmitClaimChat crashes on launch in dyld.
                scripts: [
                    .post(
                        path: .relativeToRoot("scripts/post-build-action.sh"),
                        arguments: [],
                        name: "Clean frameworks",
                        basedOnDependencyAnalysis: false
                    )
                ],
                dependencies: [.target(name: "\(name)")] + targetDependencies,
                settings: .settings(
                    base: SettingsDictionary.generatedInfoPlist.merging([
                        // Gives the app a window scene, which is what the hosted tests need
                        "INFOPLIST_KEY_UIApplicationSceneManifest_Generation": "YES",
                        "INFOPLIST_KEY_UILaunchScreen_Generation": "YES",
                        "CODE_SIGN_STYLE": "Automatic",
                    ]) { _, new in new },
                    configurations: appConfigurations,
                    defaultSettings: .app
                )
            )

            projectTargets.append(testHostTarget)
        }

        return Project(
            name: name,
            organizationName: "Hedvig",
            options: .options(
                automaticSchemesOptions: .disabled,
                disableBundleAccessors: true,
                disableSynthesizedResourceAccessors: true
            ),
            packages: [],
            settings: .settings(configurations: projectConfigurations),
            targets: projectTargets,
            // Only the app, workspace and tooling schemes are shared; modules build and test through them
            schemes: [],
            additionalFiles: name == "hGraphQL" ? [.folderReference(path: "GraphQL")] : []
        )
    }
}
