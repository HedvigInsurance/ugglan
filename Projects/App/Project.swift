import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

let sdkFrameworks: [TargetDependency] = [
    .sdk(name: "SwiftUI", type: .framework, status: .optional),
    .sdk(name: "SceneKit", type: .framework),
    .sdk(name: "AdSupport", type: .framework),
]

let ugglanConfigurations: [Configuration] = [
    .debug(
        name: "Debug",
        settings: [
            "SWIFT_VERSION": "6.0.2",
            "CODE_SIGN_STYLE": "automatic",
            "OTHER_SWIFT_FLAGS": "$(inherited) -DPRESENTATION_DEBUGGER",
        ],
        xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")
    ),
    .release(
        name: "Release",
        settings: [
            "SWIFT_VERSION": "6.0.2",
            "CODE_SIGN_STYLE": "automatic",
            "OTHER_SWIFT_FLAGS": "$(inherited) -DPRESENTATION_DEBUGGER",
        ],
        xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")
    ),
]

let hedvigConfigurations: [Configuration] = [
    .debug(
        name: "Debug",
        settings: [
            "SWIFT_VERSION": "6.0.2",
            "CODE_SIGN_STYLE": "automatic",
        ],
        xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")
    ),
    .release(
        name: "Release",
        settings: [
            "SWIFT_VERSION": "6.0.2",
            "CODE_SIGN_STYLE": "automatic",
        ],
        xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")
    ),
]

let testsConfigurations: [Configuration] = [
    .debug(
        name: "Debug",
        settings: [
            "SWIFT_VERSION": "6.0.2",
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG APP_VARIANT_STAGING",
        ],
        xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig")
    ),
    .release(
        name: "Release",
        settings: [
            "SWIFT_VERSION": "6.0.2",
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "APP_VARIANT_STAGING",
        ],
        xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig")
    ),
]

let notificationConfiguration: [Configuration] = [
    .debug(
        name: "Debug",
        settings: [
            "SWIFT_VERSION": "6.0.2",
            "OTHER_SWIFT_FLAGS": "$(inherited) -DPRESENTATION_DEBUGGER",
            "CODE_SIGN_STYLE": "automatic",
        ],
        xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")
    ),
    .release(
        name: "Release",
        settings: [
            "SWIFT_VERSION": "6.0.2",
            "OTHER_SWIFT_FLAGS": "$(inherited) -DPRESENTATION_DEBUGGER",
            "CODE_SIGN_STYLE": "automatic",
        ],
        xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")

    ),
]

let appDependencies: [TargetDependency] = [
    [
        .project(target: "hCore", path: .relativeToRoot("Projects/hCore")),
        .project(target: "hCoreUI", path: .relativeToRoot("Projects/hCoreUI")),
        .project(target: "hGraphQL", path: .relativeToRoot("Projects/hGraphQL")),
        .project(target: "Forever", path: .relativeToRoot("Projects/Forever")),
        .project(target: "Contracts", path: .relativeToRoot("Projects/Contracts")),
        .project(target: "Home", path: .relativeToRoot("Projects/Home")),
        .project(target: "Claims", path: .relativeToRoot("Projects/Claims")),
        .project(target: "SubmitClaim", path: .relativeToRoot("Projects/SubmitClaim")),
        .project(target: "Chat", path: .relativeToRoot("Projects/Chat")),
        .project(target: "Market", path: .relativeToRoot("Projects/Market")),
        .project(target: "Payment", path: .relativeToRoot("Projects/Payment")),
        .project(target: "TravelCertificate", path: .relativeToRoot("Projects/TravelCertificate")),
        .project(target: "TerminateContracts", path: .relativeToRoot("Projects/TerminateContracts")),
        .project(target: "MoveFlow", path: .relativeToRoot("Projects/MoveFlow")),
        .project(target: "Profile", path: .relativeToRoot("Projects/Profile")),
        .project(target: "Authentication", path: .relativeToRoot("Projects/Authentication")),
        .project(target: "EditCoInsured", path: .relativeToRoot("Projects/EditCoInsured")),
        .project(target: "ChangeTier", path: .relativeToRoot("Projects/ChangeTier")),
        .project(target: "Addons", path: .relativeToRoot("Projects/Addons")),
        .project(target: "CrossSell", path: .relativeToRoot("Projects/CrossSell")),
        .project(target: "Campaign", path: .relativeToRoot("Projects/Campaign")),
        .project(target: "CoreDependencies", path: .relativeToRoot("Dependencies/CoreDependencies")),
        .project(target: "AppDependencies", path: .relativeToRoot("Dependencies/AppDependencies")),
        .project(
            target: "ResourceBundledDependencies",
            path: .relativeToRoot("Dependencies/ResourceBundledDependencies")
        ),
    ],
    sdkFrameworks,
]
.flatMap { $0 }

let devAppDependencies: [TargetDependency] = {
    var dependencies = appDependencies
    dependencies.append(.target(name: "NotificationService"))
    return dependencies
}()

let prodAppDependencies: [TargetDependency] = {
    var dependencies = appDependencies
    dependencies.append(.target(name: "NotificationServiceProd"))
    return dependencies
}()

let targetScripts: [TargetScript] = [
    .post(
        path: "../../scripts/post-build-action.sh",
        arguments: [],
        name: "Clean frameworks",
        basedOnDependencyAnalysis: false
    )
]

let project = Project(
    name: "Ugglan",
    organizationName: "Hedvig",
    options: .options(
        disableBundleAccessors: true,
        disableSynthesizedResourceAccessors: true
    ),
    packages: [],
    targets: [
        Target.target(
            name: "Ugglan",
            destinations: .iOS,
            product: .app,
            bundleId: "com.hedvigForsakring.test.app",
            deploymentTargets: .iOS("16.0"),
            infoPlist: "Config/Test/Info.plist",
            sources: ["Sources/**", ""],
            resources: ["Resources/**", "Config/Test/Resources/**", "Config/PrivacyInfo.xcprivacy"],
            entitlements: "Config/Test/Ugglan.entitlements",
            scripts: targetScripts,
            dependencies: devAppDependencies,
            settings: .settings(configurations: ugglanConfigurations)
        ),
        Target.target(
            name: "AppTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.hedvig.AppTests",
            deploymentTargets: .iOS("16.0"),
            infoPlist: .default,
            sources: .sourceFilesList(globs: [.glob("Tests/**", excluding: ["Tests/UITests/**"])]),
            resources: [],
            scripts: [],
            dependencies: [
                [
                    .target(name: "Ugglan"),
                    .project(
                        target: "TestDependencies",
                        path: .relativeToRoot("Dependencies/TestDependencies")
                    ),
                ]
            ]
            .flatMap { $0 },
            settings: .settings(configurations: testsConfigurations)
        ),
        Target.target(
            name: "AppUITests",
            destinations: .iOS,
            product: .uiTests,
            bundleId: "com.hedvig.AppUITests",
            deploymentTargets: .iOS("16.0"),
            infoPlist: .default,
            sources: .sourceFilesList(globs: [.glob("Tests/UITests/**")]),
            resources: [],
            scripts: [],
            dependencies: [
                [
                    .target(name: "Ugglan"),
                    .project(
                        target: "TestDependencies",
                        path: .relativeToRoot("Dependencies/TestDependencies")
                    ),
                ]
            ]
            .flatMap { $0 },
            settings: .settings(configurations: testsConfigurations)
        ),
        Target.target(
            name: "Hedvig",
            destinations: .iOS,
            product: .app,
            bundleId: "com.hedvig.app",
            deploymentTargets: .iOS("16.0"),
            infoPlist: "Config/Production/Info.plist",
            sources: ["Sources/**"],
            resources: ["Resources/**", "Config/Production/Resources/**", "Config/PrivacyInfo.xcprivacy"],
            entitlements: "Config/Production/Hedvig.entitlements",
            scripts: targetScripts,
            dependencies: prodAppDependencies,
            settings: .settings(configurations: hedvigConfigurations)
        ),
        Target.target(
            name: "NotificationService",
            destinations: .iOS,
            product: .appExtension,
            bundleId: "com.hedvigForsakring.test.app.NotificationService",
            deploymentTargets: .iOS("16.0"),
            infoPlist: "../../Projects/NotificationService/Info.plist",
            sources: "../NotificationService/**",
            resources: ["Config/PrivacyInfo.xcprivacy"],
            entitlements: "../NotificationService/Config/Dev/NotificationService.entitlements",
            dependencies: [],
            settings: .settings(configurations: notificationConfiguration)
        ),
        Target.target(
            name: "NotificationServiceProd",
            destinations: .iOS,
            product: .appExtension,
            bundleId: "com.hedvig.app.NotificationService",
            deploymentTargets: .iOS("16.0"),
            infoPlist: "../../Projects/NotificationService/Info.plist",
            sources: "../NotificationService/**",
            resources: ["Config/PrivacyInfo.xcprivacy"],
            entitlements: "../NotificationService/Config/Prod/NotificationService.entitlements",
            dependencies: [],
            settings: .settings(configurations: notificationConfiguration)
        ),
    ],
    schemes: [
        Scheme.scheme(
            name: "Ugglan",
            shared: true,
            buildAction: BuildAction.buildAction(
                targets: ["Ugglan"]
            ),
            testAction: .targets(
                [
                    TestableTarget.testableTarget(
                        target: TargetReference(stringLiteral: "AppTests"),
                        parallelization: .enabled
                    )
                ],
                arguments: Arguments.arguments(
                    environmentVariables: [
                        "SNAPSHOT_ARTIFACTS": EnvironmentVariable.environmentVariable(
                            value: "/tmp/__SnapshotFailures__",
                            isEnabled: true
                        )
                    ],
                    launchArguments: [
                        .launchArgument(name: "-UIPreferredContentSizeCategoryName", isEnabled: true),
                        .launchArgument(name: "-UICTContentSizeCategoryM", isEnabled: true),
                    ]
                )
            ),
            runAction: .runAction(executable: "Ugglan")
        ),
        Scheme.scheme(
            name: "UITests",
            shared: true,
            buildAction: BuildAction.buildAction(
                targets: ["Ugglan"]
            ),
            testAction: .targets(
                [
                    TestableTarget.testableTarget(
                        target: TargetReference(stringLiteral: "AppUITests"),
                        parallelization: .enabled
                    )
                ],
                arguments: Arguments.arguments(
                    environmentVariables: [
                        "SNAPSHOT_ARTIFACTS": EnvironmentVariable.environmentVariable(
                            value: "/tmp/__SnapshotFailures__",
                            isEnabled: true
                        )
                    ],
                    launchArguments: [
                        .launchArgument(name: "-UIPreferredContentSizeCategoryName", isEnabled: true),
                        .launchArgument(name: "-UICTContentSizeCategoryM", isEnabled: true),
                    ]
                )
            ),
            runAction: .runAction(executable: "Ugglan")
        ),
        Scheme.scheme(
            name: "Hedvig",
            shared: true,
            buildAction: BuildAction.buildAction(
                targets: ["Hedvig"]
            ),
            runAction: .runAction(executable: "Hedvig")
        ),
    ],
    additionalFiles: []
)
