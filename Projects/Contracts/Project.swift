import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Contracts",
    targets: Set([.framework, .frameworkResources, .tests, .example, .testing]),
    projects: ["hCore", "hCoreUI"],
    externalDependenciesFor: { target in
        switch target {
        case .framework:
            return [
                ExternalDependency.hero
            ]
        default:
            return []
        }
    },
    sdks: [],
    includesGraphQL: true
)
