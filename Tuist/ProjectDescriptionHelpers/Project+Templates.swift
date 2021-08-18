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
    sdks: [String] = [],
    includesGraphQL: Bool = false
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

    let testsConfigurations: [CustomConfiguration] = [
      .debug(
        name: "Debug",
        settings: [String: SettingValue](),
        xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig")
      ),
      .release(
        name: "Release",
        settings: [String: SettingValue](),
        xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig")
      ),
    ]
    let appConfigurations: [CustomConfiguration] = [
      .debug(
        name: "Debug",
        settings: [String: SettingValue](),
        xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")
      ),
      .release(
        name: "Release",
        settings: [String: SettingValue](),
        xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")
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

    var testsDependencies: [TargetDependency] = [
      .target(name: "\(name)"),
      .project(target: "Testing", path: .relativeToRoot("Projects/Testing")),
    ]
    projects.forEach {
      testsDependencies.append(.project(target: $0, path: .relativeToRoot("Projects/\($0)")))
    }

    if targets.contains(.testing) { testsDependencies.append(.target(name: "\(name)Testing")) }

    var targetDependencies: [TargetDependency] = projects.map {
      .project(target: $0, path: .relativeToRoot("Projects/\($0)"))
    }
    targetDependencies.append(contentsOf: sdks.map { .sdk(name: $0) })
    targetDependencies.append(
      contentsOf: dependencies.map {
        .project(target: $0, path: .relativeToRoot("Dependencies/\($0)"))
      }
    )

    let hGraphQLName = "hGraphQL"

    if includesGraphQL, !projects.contains(hGraphQLName), name != hGraphQLName {
      targetDependencies.append(
        .project(target: hGraphQLName, path: .relativeToRoot("Projects/\(hGraphQLName)"))
      )
    }

    var projectTargets: [Target] = []

    if targets.contains(.framework) {
      let sources: SourceFilesList =
        includesGraphQL ? ["Sources/**/*.swift", "GraphQL/**/*.swift"] : ["Sources/**/*.swift"]

      let frameworkTarget = Target(
        name: name,
        platform: .iOS,
        product: .framework,
        bundleId: "com.hedvig.\(name)",
        deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad, .mac]),
        infoPlist: .default,
        sources: sources,
        resources: targets.contains(.frameworkResources) ? ["Resources/**"] : [],
        actions: [],
        dependencies: targetDependencies,
        settings: Settings(base: [:], configurations: frameworkConfigurations)
      )

      projectTargets.append(frameworkTarget)
    }

    if targets.contains(.testing) {
      let testingTarget = Target(
        name: "\(name)Testing",
        platform: .iOS,
        product: .framework,
        bundleId: "com.hedvig.\(name)Testing",
        deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad, .mac]),
        infoPlist: .default,
        sources: "Testing/**/*.swift",
        actions: [],
        dependencies: [
          [
            .target(name: "\(name)"),
            .project(
              target: "TestingUtil",
              path: .relativeToRoot("Projects/TestingUtil")
            ),
            .project(
              target: "DevDependencies",
              path: .relativeToRoot("Dependencies/DevDependencies")
            ),
          ], targetDependencies,
        ]
        .flatMap { $0 },
        settings: Settings(base: [:], configurations: frameworkConfigurations)
      )

      projectTargets.append(testingTarget)
    }

    if targets.contains(.tests) {
      let testTarget = Target(
        name: "\(name)Tests",
        platform: .iOS,
        product: .unitTests,
        bundleId: "com.hedvig.\(name)Tests",
        deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad, .mac]),
        infoPlist: .default,
        sources: "Tests/**/*.swift",
        actions: [],
        dependencies: [
          [
            .target(name: "\(name)Example"),
            .project(
              target: "TestingUtil",
              path: .relativeToRoot("Projects/TestingUtil")
            ),
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
        settings: Settings(base: [:], configurations: testsConfigurations)
      )

      projectTargets.append(testTarget)
    }

    if targets.contains(.example) {
      let exampleTarget = Target(
        name: "\(name)Example",
        platform: .iOS,
        product: .app,
        bundleId: "com.hedvig.example.\(name)Example",
        deploymentTarget: .iOS(targetVersion: "14.0", devices: [.iphone, .ipad, .mac]),
        infoPlist: .extendingDefault(with: [
          "UIMainStoryboardFile": "",
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
        actions: [
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
              target: "ExampleUtil",
              path: .relativeToRoot("Projects/ExampleUtil")
            ),
            .project(
              target: "TestingUtil",
              path: .relativeToRoot("Projects/TestingUtil")
            ),
            .project(
              target: "DevDependencies",
              path: .relativeToRoot("Dependencies/DevDependencies")
            ),
          ], targets.contains(.testing) ? [.target(name: "\(name)Testing")] : [],
          targetDependencies,
        ]
        .flatMap { $0 },
        settings: Settings(
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
      TestAction(
        targets: [
          TestableTarget(
            target: TargetReference(stringLiteral: "\(name)Tests"),
            parallelizable: true
          )
        ],
        arguments: Arguments(
          environment: [
            "SNAPSHOT_ARTIFACTS": "/tmp/\(UUID().uuidString)/__SnapshotFailures__"
          ],
          launchArguments: []
        ),
        coverage: true
      )
    }

    return Project(
      name: name,
      organizationName: "Hedvig",
      packages: [],
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
        targets.contains(.example)
          ? Scheme(
            name: "\(name)Example",
            shared: true,
            buildAction: BuildAction(targets: [
              TargetReference(stringLiteral: "\(name)Example")
            ]),
            testAction: getTestAction(),
            runAction: RunAction(
              executable: TargetReference(stringLiteral: "\(name)Example")
            )
          ) : nil,
      ]
      .compactMap { $0 },
      additionalFiles: [includesGraphQL ? .folderReference(path: "GraphQL") : nil].compactMap { $0 }
    )
  }
}
