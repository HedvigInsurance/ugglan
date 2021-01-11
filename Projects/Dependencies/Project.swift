import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.dependenciesFramework(
    name: "Dependencies",
    externalDependencies: ExternalDependencies.allCases.filter { !$0.isTestDependency }
)
