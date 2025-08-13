import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.dependenciesFramework(
    name: "ResourceBundledDependencies",
    externalDependencies: ExternalDependencies.allCases.filter(\.isResourceBundledDependency)
)
