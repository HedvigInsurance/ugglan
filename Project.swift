import ProjectDescription
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
        .package(url: "https://github.com/yannickl/DynamicColor.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/saoudrizwan/Disk.git", .upToNextMajor(from: "0.6.4")),
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1")),
        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "5.13.1")),
    ],
    settings: Settings(
     base: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "APP_VARIANT_STAGING"],
     configurations: [
            .debug(
                name: "debug",
                settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "APP_VARIANT_STAGING"],
                xcconfig: nil
            ),
            .release(
                name: "debug",
                settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "APP_VARIANT_STAGING"],
                xcconfig: nil
            ),
    ],
     defaultSettings: .recommended
    ),
    targets: [
        Target(
            name: "Ugglan",
           platform: .iOS,
           product: .app,
           bundleId: "com.hedvig.test.app",
           deploymentTarget: .iOS(targetVersion: "12.0", devices: [.iphone, .ipad, .mac]),
           infoPlist: "Config/Test/Info.plist",
           sources: ["Src/**", "AppSpecific/**"],
           resources: ["Resources/**", "Config/Test/Resources/**"],
           dependencies: [
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
            .package(product: "Kingfisher"),
            .package(product: "MarkdownKit")
        ])
    ]
)
