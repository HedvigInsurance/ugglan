import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.dependenciesFramework(
  name: "AppDependencies",
  externalDependencies: ExternalDependencies.allCases.filter { $0.isAppDependency }
)
