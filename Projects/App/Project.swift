import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

let sdkFrameworks: [TargetDependency] = [
	.sdk(name: "libc++.tbd"), .sdk(name: "libz.tbd"), .sdk(name: "SwiftUI.framework", status: .optional),
	.sdk(name: "SceneKit.framework"), .sdk(name: "AdSupport.framework"),
]

let supportedPlatforms = SettingValue("iphonesimulator iphoneos macosx")

let ugglanConfigurations: [CustomConfiguration] = [
	.debug(
		name: "Debug",
		settings: [
            "PROVISIONING_PROFILE_SPECIFIER[sdk=iphone*]":
                "match Development com.hedvig.test.app",
            "PROVISIONING_PROFILE_SPECIFIER[sdk=macosx*]":
                "match Development com.hedvig.test.app catalyst",
            "SUPPORTED_PLATFORMS": supportedPlatforms
        ],
		xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")
	),
	.release(
		name: "Release",
		settings: [
            "CODE_SIGN_IDENTITY[sdk=macosx*]":
                "Apple Distribution: Hedvig AB (AW656G5PFM)",
            "SUPPORTED_PLATFORMS": supportedPlatforms
        ],
		xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")
	),
]

let hedvigConfigurations: [CustomConfiguration] = [
	.debug(
		name: "Debug",
		settings: [
            "PROVISIONING_PROFILE_SPECIFIER[sdk=iphone*]":
                "match Development com.hedvig.app",
            "PROVISIONING_PROFILE_SPECIFIER[sdk=macosx*]":
                "match Development com.hedvig.app catalyst",
            "SUPPORTED_PLATFORMS": supportedPlatforms
        ],
		xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")
	),
	.release(
		name: "Release",
		settings: [
            "SUPPORTED_PLATFORMS": supportedPlatforms
        ],
		xcconfig: .relativeToRoot("Configurations/iOS/iOS-Application.xcconfig")
	),
]

let testsConfigurations: [CustomConfiguration] = [
	.debug(
		name: "Debug",
		settings: [
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG APP_VARIANT_STAGING",
            "SUPPORTED_PLATFORMS": supportedPlatforms
        ],
		xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig")
	),
	.release(
		name: "Release",
		settings: [
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "APP_VARIANT_STAGING",
            "SUPPORTED_PLATFORMS": supportedPlatforms
        ],
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
		.project(target: "Market", path: .relativeToRoot("Projects/Market")),
		.project(target: "Payment", path: .relativeToRoot("Projects/Payment")),
		.project(target: "CoreDependencies", path: .relativeToRoot("Dependencies/CoreDependencies")),
        .project(target: "AppDependencies", path: .relativeToRoot("Dependencies/AppDependencies")),
        .project(target: "NonMacDependencies", path: .relativeToRoot("Dependencies/NonMacDependencies")),
		.project(
			target: "ResourceBundledDependencies",
			path: .relativeToRoot("Dependencies/ResourceBundledDependencies")
		), .project(target: "Embark", path: .relativeToRoot("Projects/Embark")),
	], sdkFrameworks,
]
.flatMap { $0 }

let targetActions: [TargetAction] = [
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
			deploymentTarget: .iOS(targetVersion: "12.0", devices: [.iphone, .ipad, .mac]),
			infoPlist: "Config/Test/Info.plist",
			sources: ["Sources/**"],
			resources: ["Resources/**", "Config/Test/Resources/**"],
			entitlements: "Config/Test/Ugglan.entitlements",
			actions: targetActions,
			dependencies: appDependencies,
			settings: Settings(configurations: ugglanConfigurations)
		),
		Target(
			name: "AppTests",
			platform: .iOS,
			product: .unitTests,
			bundleId: "com.hedvig.AppTests",
			deploymentTarget: .iOS(targetVersion: "12.0", devices: [.iphone, .ipad, .mac]),
			infoPlist: .default,
			sources: ["Tests/**"],
			resources: [],
			actions: targetActions,
			dependencies: [
				[
					.target(name: "Ugglan"),
					.project(
						target: "TestDependencies",
						path: .relativeToRoot("Dependencies/TestDependencies")
					), .project(target: "Testing", path: .relativeToRoot("Projects/Testing")),
				]
			]
			.flatMap { $0 },
			settings: Settings(configurations: testsConfigurations)
		),
		Target(
			name: "Hedvig",
			platform: .iOS,
			product: .app,
			bundleId: "com.hedvig.app",
			deploymentTarget: .iOS(targetVersion: "12.0", devices: [.iphone, .ipad, .mac]),
			infoPlist: "Config/Production/Info.plist",
			sources: ["Sources/**"],
			resources: ["Resources/**", "Config/Production/Resources/**"],
			entitlements: "Config/Production/Hedvig.entitlements",
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
				targets: [
					TestableTarget(
						target: TargetReference(stringLiteral: "AppTests"),
						parallelizable: true
					)
				],
				arguments: Arguments(
					environment: ["SNAPSHOT_ARTIFACTS": "/tmp/__SnapshotFailures__"],
					launchArguments: [
						"-UIPreferredContentSizeCategoryName": true,
						"UICTContentSizeCategoryM": true,
					]
				)
			),
			runAction: RunAction(executable: "Ugglan")
		),
		Scheme(
			name: "Hedvig",
			shared: true,
			buildAction: BuildAction(targets: ["Hedvig"]),
			runAction: RunAction(executable: "Hedvig")
		),
	],
	additionalFiles: [.folderReference(path: "GraphQL")]
)
