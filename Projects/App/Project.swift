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
            "CODE_SIGN_STYLE": "automatic",
            "OTHER_SWIFT_FLAGS": "$(inherited) -DPRESENTATION_DEBUGGER",
        ],
        xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")
    ),
    .release(
        name: "Release",
        settings: [
            "CODE_SIGN_STYLE": "automatic",
            "OTHER_SWIFT_FLAGS": "$(inherited) -DPRESENTATION_DEBUGGER",
        ],
        xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")
    ),
]

let hedvigConfigurations: [Configuration] = [
    .debug(
        name: "Debug",
        settings: ["CODE_SIGN_STYLE": "automatic"],
        xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")
    ),
    .release(
        name: "Release",
        settings: ["CODE_SIGN_STYLE": "automatic"],
        xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")
    ),
]

let testsConfigurations: [Configuration] = [
    .debug(
        name: "Debug",
        settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG APP_VARIANT_STAGING"],
        xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig")
    ),
    .release(
        name: "Release",
        settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "APP_VARIANT_STAGING"],
        xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig")
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
        .project(target: "Market", path: .relativeToRoot("Projects/Market")),
        .project(target: "Payment", path: .relativeToRoot("Projects/Payment")),
        .project(target: "TravelCertificate", path: .relativeToRoot("Projects/TravelCertificate")),
        .project(target: "TerminateContracts", path: .relativeToRoot("Projects/TerminateContracts")),
        .project(target: "MoveFlow", path: .relativeToRoot("Projects/MoveFlow")),
        .project(target: "Profile", path: .relativeToRoot("Projects/Profile")),
        .project(target: "Authentication", path: .relativeToRoot("Projects/Authentication")),
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

let targetScripts: [TargetScript] = [
    .post(path: "../../scripts/post-build-action.sh", arguments: [], name: "Clean frameworks")
]

let project = Project(
    name: "Ugglan",
    organizationName: "Hedvig",
    packages: [],
    targets: [
        Target(
            name: "Ugglan",
            platform: .iOS,
            product: .app,
            bundleId: "com.hedvig.test.app",
            deploymentTarget: .iOS(targetVersion: "14.0", devices: [.iphone, .ipad]),
            infoPlist: "Config/Test/Info.plist",
            sources: ["Sources/**"],
            resources: ["Resources/**", "Config/Test/Resources/**"],
            entitlements: "Config/Test/Ugglan.entitlements",
            scripts: targetScripts,
            dependencies: appDependencies,
            settings: .settings(configurations: ugglanConfigurations)
        ),
        Target(
            name: "NotificationService",
            platform: .iOS,
            product: .app,
            bundleId: "com.hedvig.app",
            deploymentTarget: .iOS(targetVersion: "14.0", devices: [.iphone, .ipad]),
            infoPlist: "Config/Production/Info.plist",
            sources: ["Sources/**"],
            resources: ["Resources/**", "Config/Test/Resources/**"],
            //            entitlements: "Config/Production/NotificationService.entitlements",
            scripts: targetScripts,
            dependencies: appDependencies,
            settings: .settings(configurations: ugglanConfigurations)
        ),
        Target(
            name: "AppTests",
            platform: .iOS,
            product: .unitTests,
            bundleId: "com.hedvig.AppTests",
            deploymentTarget: .iOS(targetVersion: "14.0", devices: [.iphone, .ipad]),
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            scripts: targetScripts,
            dependencies: [
                [
                    .target(name: "Ugglan"),
                    .project(
                        target: "TestDependencies",
                        path: .relativeToRoot("Dependencies/TestDependencies")
                    ),
                    .project(target: "Testing", path: .relativeToRoot("Projects/Testing")),
                ]
            ]
            .flatMap { $0 },
            settings: .settings(configurations: testsConfigurations)
        ),
        Target(
            name: "Hedvig",
            platform: .iOS,
            product: .app,
            bundleId: "com.hedvig.app",
            deploymentTarget: .iOS(targetVersion: "14.0", devices: [.iphone, .ipad]),
            infoPlist: "Config/Production/Info.plist",
            sources: ["Sources/**"],
            resources: ["Resources/**", "Config/Production/Resources/**"],
            entitlements: "Config/Production/Hedvig.entitlements",
            scripts: targetScripts,
            dependencies: appDependencies,
            settings: .settings(configurations: hedvigConfigurations)
        ),
    ],
    schemes: [
        Scheme(
            name: "Ugglan",
            shared: true,
            buildAction: BuildAction(
                targets: ["Ugglan"]
            ),
            testAction: .targets(
                [
                    TestableTarget(
                        target: TargetReference(stringLiteral: "AppTests"),
                        parallelizable: true
                    )
                ],
                arguments: Arguments(
                    environment: [
                        "SNAPSHOT_ARTIFACTS": "/tmp/__SnapshotFailures__"
                    ],
                    launchArguments: [
                        .init(name: "-UIPreferredContentSizeCategoryName", isEnabled: true),
                        .init(name: "-UICTContentSizeCategoryM", isEnabled: true),
                    ]
                )
            ),
            runAction: .runAction(executable: "Ugglan")
        ),
        Scheme(
            name: "Hedvig",
            shared: true,
            buildAction: BuildAction(
                targets: ["Hedvig"]
            ),
            runAction: .runAction(executable: "Hedvig")
        ),
    ],
    additionalFiles: [
        .folderReference(path: "GraphQL")
    ]
)
