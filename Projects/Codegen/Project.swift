import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Codegen",
    organizationName: "Hedvig AB",
    packages: ExternalDependencies.apollo.swiftPackages() + ExternalDependencies.apolloIosCodegen.swiftPackages()
        + ExternalDependencies.argumentParser.swiftPackages(),
    settings: .settings(base: [
        // Xcode 27 recommendations. Codegen has no script phases, so sandboxing changes nothing.
        "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
        "STRING_CATALOG_GENERATE_SYMBOLS": "YES",
    ]),
    targets: [
        Target.target(
            name: "Codegen",
            destinations: .macOS,
            product: .app,
            bundleId: "com.hedvig.codegen",
            deploymentTargets: .macOS("14.0"),
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
