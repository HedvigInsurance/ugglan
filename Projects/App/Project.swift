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
    .release(name: "Release", settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "APP_VARIANT_STAGING"], xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig"))
]

let hedvigConfigurations: [CustomConfiguration] = [
    .debug(name: "Debug", settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG APP_VARIANT_PRODUCTION"], xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")),
    .release(name: "Release", settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "APP_VARIANT_PRODUCTION"], xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig"))
]

let testsConfigurations: [CustomConfiguration] = [
    .debug(name: "Debug", settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG APP_VARIANT_STAGING"], xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig")),
    .release(name: "Release", settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "APP_VARIANT_STAGING"], xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig"))
]

let testsRecordConfigurations: [CustomConfiguration] = [
    .debug(name: "Debug", settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG APP_VARIANT_STAGING RECORD_MODE"], xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig")),
    .release(name: "Release", settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "APP_VARIANT_STAGING RECORD_MODE"], xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig"))
]

let appDependencies: [TargetDependency] = [
    [
        .project(target: "hCore", path: .relativeToRoot("Projects/hCore")),
        .project(target: "hCoreUI", path: .relativeToRoot("Projects/hCoreUI"))
    ],
    sdkFrameworks,
    ExternalDependencies.allCases.map { externalDependency in
        externalDependency.targetDependencies()
    }.flatMap { $0 }
].flatMap { $0 }

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
            actions: [],
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
            dependencies: [
                [.target(name: "Ugglan"),
                 .framework(path: "../../Carthage/Build/iOS/SnapshotTesting.framework")],
            ].flatMap { $0 },
            settings: Settings(configurations: testsConfigurations)
        ),
        Target(
            name: "AppTestsRecord",
            platform: .iOS,
            product: .unitTests,
            bundleId: "com.hedvig.AppTests",
            deploymentTarget: .iOS(targetVersion: "12.0", devices: [.iphone, .ipad]),
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [
                [.target(name: "Ugglan"),
                 .framework(path: "../../Carthage/Build/iOS/SnapshotTesting.framework")],
            ].flatMap { $0 },
            settings: Settings(configurations: testsRecordConfigurations)
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
            dependencies: appDependencies,
            settings: Settings(configurations: hedvigConfigurations)
        ),
    ],
    schemes: [
        Scheme(
            name: "Ugglan",
            shared: true,
            buildAction: BuildAction(targets: ["Ugglan"]),
            runAction: RunAction(executable: "Ugglan")
        ),
        Scheme(
            name: "Hedvig",
            shared: true,
            buildAction: BuildAction(targets: ["Hedvig"]),
            runAction: RunAction(executable: "Hedvig")
        ),
        Scheme(
            name: "AppTests",
            shared: true,
            buildAction: BuildAction(targets: ["Ugglan"]),
            testAction: TestAction(targets: ["AppTests"]),
            runAction: RunAction(executable: "Ugglan", arguments: Arguments(environment: ["SNAPSHOT_ARTIFACTS": "$(PROJECT_DIR)/Tests/__SnapshotFailures__"], launch: [:]))
        ),
        Scheme(
            name: "AppTests Record",
            shared: true,
            buildAction: BuildAction(targets: ["Ugglan"]),
            testAction: TestAction(targets: ["AppTestsRecord"]),
            runAction: RunAction(executable: "Ugglan", arguments: Arguments(environment: ["SNAPSHOT_ARTIFACTS": "$(PROJECT_DIR)/Tests/__SnapshotFailures__"], launch: [:]))
        ),
    ]
)
