import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Codegen",
    organizationName: "Hedvig AB",
    packages: ExternalDependencies.apollo.swiftPackages() + ExternalDependencies.apolloIosCodegen.swiftPackages()
        + ExternalDependencies.argumentParser.swiftPackages(),
    targets: [
        Target.target(
            name: "Codegen",
            destinations: .macOS,
            product: .app,
            bundleId: "com.hedvig.codegen",
            deploymentTargets: .macOS("13.0"),
            infoPlist: "Info.plist",
            sources: ["Sources/**"],
            resources: [],
            dependencies: [
                .package(product: "ApolloCodegenLib"),
                .package(product: "ArgumentParser"),
            ]
        )
    ],
    schemes: [
        Scheme.scheme(
            name: "Apollo Codegen",
            shared: true,
            buildAction: BuildAction.buildAction(targets: ["Codegen"]),
            runAction: .runAction(executable: .init(stringLiteral: "Codegen"))
        )
    ]
)
