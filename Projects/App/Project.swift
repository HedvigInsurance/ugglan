import ProjectDescription

let carthageFrameworks: [TargetDependency] = [
    .framework(path: "../../Carthage/Build/iOS/Adyen.framework"),
    .framework(path: "../../Carthage/Build/iOS/Adyen3DS2.framework"),
    .framework(path: "../../Carthage/Build/iOS/AdyenCard.framework"),
    .framework(path: "../../Carthage/Build/iOS/AdyenDropIn.framework"),
    .framework(path: "../../Carthage/Build/iOS/Crashlytics.framework"),
    .framework(path: "../../Carthage/Build/iOS/Fabric.framework"),
    .framework(path: "../../Carthage/Build/iOS/FBSDKCoreKit.framework"),
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
    .framework(path: "../../Carthage/Build/iOS/FirebaseRemoteConfig.framework"),
    .framework(path: "../../Carthage/Build/iOS/FirebaseDynamicLinks.framework"),
    .framework(path: "../../Carthage/Build/iOS/FirebaseAnalytics.framework"),
    .framework(path: "../../Carthage/Build/iOS/FirebaseCore.framework"),
    .framework(path: "../../Carthage/Build/iOS/abseil.framework"),
    .framework(path: "../../Carthage/Build/iOS/nanopb.framework"),
    .framework(path: "../../Carthage/Build/iOS/Instabug.framework"),
    .framework(path: "../../Carthage/Build/iOS/Kingfisher.framework")
]

let spmFrameworks: [TargetDependency] = [
    .package(product: "Apollo"),
    .package(product: "ApolloWebSocket"),
    .package(product: "Flow"),
    .package(product: "Form"),
    .package(product: "Presentation"),
    .package(product: "FlowFeedback"),
    .package(product: "UICollectionView-AnimatedScroll"),
    .package(product: "Ease"),
    .package(product: "DynamicColor"),
    .package(product: "Disk"),
    .package(product: "SnapKit"),
    .package(product: "MarkdownKit"),
]

let sdkFrameworks: [TargetDependency] = [
    .sdk(name: "libc++.tbd"),
    .sdk(name: "libz.tbd"),
    .sdk(name: "SwiftUI.framework", status: .optional),
    .sdk(name: "SceneKit.framework"),
    .sdk(name: "AdSupport.framework")
]


func +<Key, Value>(l: Dictionary<Key, Value>, r: Dictionary<Key, Value>) -> Dictionary<Key, Value> {
    var newDict = Dictionary<Key, Value>()
    
    for (key, value) in l {
        newDict[key] = value
    }
    
    for (key, value) in r {
        newDict[key] = value
    }
    
    return newDict
}

let team = "AW656G5PFM"

let baseSettings: [String: SettingValue] = [
    "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "APP_VARIANT_STAGING",
    "OTHER_LDFLAGS": "-ObjC",
    "DEVELOPMENT_TEAM": "AW656G5PFM",
    "SDKROOT": "iphoneos"
]

let stagingDebugSettings = baseSettings + ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG APP_VARIANT_STAGING"]
let stagingReleaseSettings = baseSettings + ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "APP_VARIANT_STAGING"]

let stagingSettings = Settings(
    base: baseSettings,
    configurations: [
        .debug(
            name: "debug",
            settings: stagingDebugSettings,
            xcconfig: nil
        ),
        .release(
            name: "release",
            settings: stagingReleaseSettings,
            xcconfig: nil
        ),
    ],
    defaultSettings: .recommended
)

let productionDebugSettings = baseSettings + ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG APP_VARIANT_PRODUCTION"]
let productionReleaseSettings = baseSettings + ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "APP_VARIANT_PRODUCTION"]

let productionSettings = Settings(
    base: baseSettings,
    configurations: [
        .debug(
            name: "debug",
            settings: productionDebugSettings,
            xcconfig: nil
        ),
        .release(
            name: "release",
            settings: productionReleaseSettings,
            xcconfig: nil
        ),
    ],
    defaultSettings: .recommended
)

let unitTestsSettings = Settings(
    base: baseSettings,
    configurations: [
        .debug(
            name: "debug",
            settings: stagingDebugSettings,
            xcconfig: nil
        ),
    ],
    defaultSettings: .recommended
)

let unitTestsRecordSettings = Settings(
    base: baseSettings,
    configurations: [
        .debug(
            name: "debug",
            settings: stagingDebugSettings,
            xcconfig: nil
        ),
    ],
    defaultSettings: .recommended
)

let project = Project(
    name: "Ugglan",
    organizationName: "Hedvig AB",
    packages: [
        .package(url: "https://github.com/apollographql/apollo-ios.git", .upToNextMajor(from: "0.25.0")),
        .package(url: "https://github.com/HedvigInsurance/flow.git", .branch("master")),
        .package(url: "https://github.com/HedvigInsurance/form.git", .branch("master")),
        .package(url: "https://github.com/HedvigInsurance/presentation.git", .branch("master")),
        .package(url: "https://github.com/HedvigInsurance/flowfeedback.git", .branch("master")),
        .package(url: "https://github.com/HedvigInsurance/UICollectionView-AnimatedScroll.git", .branch("master")),
        .package(url: "https://github.com/HedvigInsurance/ease.git", .branch("master")),
        .package(url: "https://github.com/hedviginsurance/MarkdownKit.git", .branch("master")),
        .package(url: "https://github.com/yannickl/DynamicColor.git", .upToNextMajor(from: "4.2.1")),
        .package(url: "https://github.com/saoudrizwan/Disk.git", .upToNextMajor(from: "0.6.4")),
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1")),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", .upToNextMajor(from: "1.7.2"))
    ],
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
            dependencies: [
                spmFrameworks,
                carthageFrameworks,
                sdkFrameworks
            ].flatMap { $0 },
            settings: stagingSettings
        ),
        Target(
            name: "Ugglan-UnitTests",
            platform: .iOS,
            product: .unitTests,
            bundleId: "com.hedvig.test.unittests",
            deploymentTarget: .iOS(targetVersion: "12.0", devices: [.iphone, .ipad]),
            infoPlist: "UnitTests/Info.plist",
            sources: ["UnitTests/**"],
            resources: [],
            dependencies: [
                [.target(name: "Ugglan"),
                .package(product: "SnapshotTesting")]
            ].flatMap { $0 },
            settings: unitTestsSettings
        ),
        Target(
            name: "Ugglan-UnitTests-Record",
            platform: .iOS,
            product: .unitTests,
            bundleId: "com.hedvig.test.unittests",
            deploymentTarget: .iOS(targetVersion: "12.0", devices: [.iphone, .ipad]),
            infoPlist: "UnitTests/Info.plist",
            sources: ["UnitTests/**"],
            resources: [],
            dependencies: [
                [.target(name: "Ugglan"),
                .package(product: "SnapshotTesting")]
            ].flatMap { $0 },
            settings: unitTestsRecordSettings
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
            dependencies: [
                spmFrameworks,
                carthageFrameworks,
                sdkFrameworks
            ].flatMap { $0 },
            settings: productionSettings
        )
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
            name: "UnitTests",
            shared: true,
            buildAction: BuildAction(targets: ["Ugglan"]),
            testAction: TestAction(targets: ["Ugglan-UnitTests"]),
            runAction: RunAction(executable: "Ugglan")
        ),
        Scheme(
            name: "UnitTests Record Snapshots",
            shared: true,
            buildAction: BuildAction(targets: ["Ugglan"]),
            testAction: TestAction(targets: ["Ugglan-UnitTests-Record"]),
            runAction: RunAction(executable: "Ugglan")
        ),
    ]
)
