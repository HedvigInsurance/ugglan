import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "hGraphQL",
    targets: Set([.framework]),
    projects: [],
    externalDependenciesFor: { target in
        switch target {
        case .framework:
            return [
                ExternalDependency.apollo,
                ExternalDependency.flow,
                ExternalDependency.disk
            ]
        default:
            return []
        }
    },
    sdks: [],
    includesGraphQL: true
)
