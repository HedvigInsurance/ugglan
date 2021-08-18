import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.dependenciesFramework(
	name: "NonMacDependencies",
	externalDependencies: ExternalDependencies.allCases.filter { $0.isNonMacDependency },
    supportsMacCatalyst: false
)
