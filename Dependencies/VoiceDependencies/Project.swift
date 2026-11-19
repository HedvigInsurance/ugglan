import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.dependenciesFramework(
    name: "VoiceDependencies",
    externalDependencies: ExternalDependencies.allCases.filter(\.isVoiceDependency)
)
