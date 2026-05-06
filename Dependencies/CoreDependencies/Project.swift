import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.dependenciesFramework(
    name: "CoreDependencies",
    externalDependencies: ExternalDependencies.allCases.filter(\.isCoreDependency),
    scripts: [
        .pre(
            path: "../../scripts/build-local-umbrella.sh",
            name: "Build HedvigShared (local umbrella mode)",
            basedOnDependencyAnalysis: false
        )
    ]
)
