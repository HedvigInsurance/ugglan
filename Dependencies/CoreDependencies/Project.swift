import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.dependenciesFramework(
    name: "CoreDependencies",
    externalDependencies: ExternalDependencies.allCases.filter { !$0.isTestDependency }.filter { !$0.isDevDependency }
)
