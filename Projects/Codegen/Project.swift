import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
	name: "Codegen",
	organizationName: "Hedvig AB",
	packages: ExternalDependencies.apollo.swiftPackages(),
	targets: [
		Target(
			name: "Codegen",
			platform: .macOS,
			product: .app,
			bundleId: "com.hedvig.codegen",
			infoPlist: "Info.plist",
			sources: ["Sources/**"],
			resources: [],
			dependencies: [.package(product: "ApolloCodegenLib")]
		)
	],
	schemes: [
		Scheme(
			name: "Apollo Codegen",
			shared: true,
			buildAction: BuildAction(targets: ["Codegen"]),
			runAction: RunAction(executable: "Codegen")
		)
	]
)
