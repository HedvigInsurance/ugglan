import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

let sdkFrameworks: [TargetDependency] = [
    .sdk(name: "libc++.tbd"),
    .sdk(name: "libz.tbd"),
    .sdk(name: "SwiftUI.framework", status: .optional),
    .sdk(name: "SceneKit.framework"),
    .sdk(name: "AdSupport.framework"),
]

let ugglanConfigurations: [Configuration] = [
    .debug(
        name: "Debug",
        settings: [
            "PROVISIONING_PROFILE_SPECIFIER": "match Development com.hedvig.test.app",
            "OTHER_SWIFT_FLAGS": "$(inherited) -DPRESENTATION_DEBUGGER",
        ],
        xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")
    ),
    .release(
        name: "Release",
        settings: ["OTHER_SWIFT_FLAGS": "$(inherited) -DPRESENTATION_DEBUGGER"],
        xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")
    ),
]

let hedvigConfigurations: [Configuration] = [
    .debug(
        name: "Debug",
        settings: ["PROVISIONING_PROFILE_SPECIFIER": "match Development com.hedvig.app"],
        xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")
    ),
    .release(
        name: "Release",
        settings: [:],
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
        .project(target: "Offer", path: .relativeToRoot("Projects/Offer")),
        .project(target: "Market", path: .relativeToRoot("Projects/Market")),
        .project(target: "Payment", path: .relativeToRoot("Projects/Payment")),
        .project(target: "Authentication", path: .relativeToRoot("Projects/Authentication")),
        .project(target: "CoreDependencies", path: .relativeToRoot("Dependencies/CoreDependencies")),
        .project(target: "AppDependencies", path: .relativeToRoot("Dependencies/AppDependencies")),
        .project(
            target: "ResourceBundledDependencies",
            path: .relativeToRoot("Dependencies/ResourceBundledDependencies")
        ),
        .project(target: "Embark", path: .relativeToRoot("Projects/Embark")),
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
            deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
            infoPlist: "Config/Test/Info.plist",
            sources: ["Sources/**"],
            resources: ["Resources/**", "Config/Test/Resources/**"],
            entitlements: "Config/Test/Ugglan.entitlements",
            scripts: targetScripts,
            dependencies: [
                appDependencies,
                [.target(name: "Ugglan-AppClip")],
            ]
            .flatMap { $0 },
            settings: .settings(configurations: ugglanConfigurations)
        ),
        Target(
            name: "AppTests",
            platform: .iOS,
            product: .unitTests,
            bundleId: "com.hedvig.AppTests",
            deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
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
            deploymentTarget: .iOS(targetVersion: "13.0", devices: [.iphone, .ipad]),
            infoPlist: "Config/Production/Info.plist",
            sources: ["Sources/**"],
            resources: ["Resources/**", "Config/Production/Resources/**"],
            entitlements: "Config/Production/Hedvig.entitlements",
            scripts: targetScripts,
            dependencies: appDependencies,
            settings: .settings(configurations: hedvigConfigurations)
        ),
        Target(
            name: "Ugglan-AppClip",
            platform: .iOS,
            product: .appClip,
            bundleId: "com.hedvig.test.app.clip",
            deploymentTarget: .iOS(targetVersion: "14.0", devices: [.iphone, .ipad]),
            infoPlist: "Config/Test/AppClip.Info.plist",
            sources: ["AppClip/Sources/**"],
            resources: ["Resources/**", "Config/Test/Resources/**"],
            entitlements: "Config/Test/AppClip.entitlements",
            scripts: targetScripts,
            dependencies: [
                appDependencies,
                [.sdk(name: "AppClip.framework", status: .required)],
            ]
            .flatMap { $0 },
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
