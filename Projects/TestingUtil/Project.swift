import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "TestingUtil",
    targets: Set([.framework]),
    projects: ["hCore"],
    externalDependenciesFor: { target in
        switch target {
        case .framework:
            return [
                ExternalDependency.apollo,
                ExternalDependency.flow,
            ]
        default:
            return []
        }
    },
    sdks: [],
    includesGraphQL: false
)
