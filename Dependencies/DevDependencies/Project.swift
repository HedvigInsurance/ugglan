import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.dependenciesFramework(
	name: "DevDependencies",
	externalDependencies: ExternalDependencies.allCases.filter { $0.isDevDependency },
	sdks: []
)
