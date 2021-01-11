import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.dependenciesFramework(
    name: "TestDependencies",
    externalDependencies: ExternalDependencies.allCases.filter { $0.isTestDependency }
)
