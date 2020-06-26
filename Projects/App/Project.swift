import ProjectDescription
import ProjectDescriptionHelpers

let sdkFrameworks: [TargetDependency] = [
    .sdk(name: "libc++.tbd"),
    .sdk(name: "libz.tbd"),
    .sdk(name: "SwiftUI.framework", status: .optional),
    .sdk(name: "SceneKit.framework"),
    .sdk(name: "AdSupport.framework"),
]

let ugglanConfigurations: [CustomConfiguration] = [
    .debug(name: "Debug", settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG APP_VARIANT_STAGING"], xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")),
    .release(name: "Release", settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "APP_VARIANT_STAGING"], xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")),
]

let hedvigConfigurations: [CustomConfiguration] = [
    .debug(name: "Debug", settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG APP_VARIANT_PRODUCTION"], xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")),
    .release(name: "Release", settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "APP_VARIANT_PRODUCTION"], xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")),
]

let testsConfigurations: [CustomConfiguration] = [
    .debug(name: "Debug", settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG APP_VARIANT_STAGING"], xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig")),
    .release(name: "Release", settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "APP_VARIANT_STAGING"], xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig")),
]

let appDependencies: [TargetDependency] = [
    [
        .project(target: "hCore", path: .relativeToRoot("Projects/hCore")),
        .project(target: "hCoreUI", path: .relativeToRoot("Projects/hCoreUI")),
        .project(target: "Forever", path: .relativeToRoot("Projects/Forever")),
    ],
    sdkFrameworks,
    ExternalDependencies.allCases.map { externalDependency in
        externalDependency.targetDependencies()
    }.flatMap { $0 },
].flatMap { $0 }

let targetActions: [TargetAction] = [
    .pre(path: "../../scripts/build_copy.sh", name: "Copy third party frameworks and applications"),
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
            deploymentTarget: .iOS(targetVersion: "12.0", devices: [.iphone, .ipad]),
            infoPlist: "Config/Test/Info.plist",
            sources: ["Sources/**"],
            resources: ["Resources/**", "Config/Test/Resources/**"],
            actions: targetActions,
            dependencies: appDependencies,
            settings: Settings(configurations: ugglanConfigurations)
        ),
        Target(
            name: "AppTests",
            platform: .iOS,
            product: .unitTests,
            bundleId: "com.hedvig.AppTests",
            deploymentTarget: .iOS(targetVersion: "12.0", devices: [.iphone, .ipad]),
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            actions: targetActions,
            dependencies: [
                [.target(name: "Ugglan"),
                 .framework(path: "../../Carthage/Build/iOS/SnapshotTesting.framework"),
                 .project(target: "Testing", path: .relativeToRoot("Projects/Testing"))],
            ].flatMap { $0 },
            settings: Settings(configurations: testsConfigurations)
        ),
        Target(
            name: "Hedvig",
            platform: .iOS,
            product: .app,
            bundleId: "com.hedvig.app",
            deploymentTarget: .iOS(targetVersion: "12.0", devices: [.iphone, .ipad]),
            infoPlist: "Config/Production/Info.plist",
            sources: ["Sources/**"],
            resources: ["Resources/**", "Config/Production/Resources/**"],
            actions: targetActions,
            dependencies: appDependencies,
            settings: Settings(configurations: hedvigConfigurations)
        ),
    ],
    schemes: [
        Scheme(
            name: "Ugglan",
            shared: true,
            buildAction: BuildAction(targets: ["Ugglan"]),
            testAction: TestAction(
                targets: [TestableTarget(target: TargetReference(stringLiteral: "AppTests"), parallelizable: true)],
                arguments: Arguments(environment: ["SNAPSHOT_ARTIFACTS": "/tmp/__SnapshotFailures__"], launch: ["-UIPreferredContentSizeCategoryName": true, "UICTContentSizeCategoryM": true])
            ),
            runAction: RunAction(executable: "Ugglan")
        ),
        Scheme(
            name: "Hedvig",
            shared: true,
            buildAction: BuildAction(targets: ["Hedvig"]),
            runAction: RunAction(executable: "Hedvig")
        ),
    ]
)
