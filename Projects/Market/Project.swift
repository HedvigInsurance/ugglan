import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Market",
    targets: Set([.framework, .frameworkResources, .tests, .example, .testing]),
    projects: ["hCore", "hCoreUI"],
    externalDependenciesFor: { target in
        switch target {
        case .framework:
            return [
                ExternalDependency.kingfisher
            ]
        default:
            return []
        }
    },
    sdks: [],
    includesGraphQL: true
)
