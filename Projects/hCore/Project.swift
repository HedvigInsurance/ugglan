import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "hCore",
    targets: Set([.framework, .frameworkResources, .tests, .example, .testing]),
    projects: ["hGraphQL"],
    externalDependenciesFor: { target in
        switch target {
        case .framework:
            return [
                ExternalDependency.flow,
                ExternalDependency.form,
                ExternalDependency.presentation,
                ExternalDependency.snapkit
            ]
        default:
            return []
        }
    },
    sdks: [],
    includesGraphQL: false
)
