import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Codegen",
    organizationName: "Hedvig AB",
    packages: ExternalDependencies.apollo.swiftPackages() + ExternalDependencies.apolloIosCodegen.swiftPackages()
        + ExternalDependencies.argumentParser.swiftPackages(),
    targets: [
        Target(
            name: "Codegen",
            platform: .macOS,
            product: .app,
            bundleId: "com.hedvig.codegen",
            deploymentTarget: .macOS(targetVersion: "12.0"),
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
        Scheme(
            name: "Apollo Codegen",
            shared: true,
            buildAction: BuildAction(targets: ["Codegen"]),
            runAction: .runAction(executable: .init(stringLiteral: "Codegen"))
        )
    ]
)
