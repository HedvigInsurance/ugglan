import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "hCoreUI",
    targets: Set([.framework, .frameworkResources, .tests, .example, .testing]),
    projects: ["hCore"],
    externalDependenciesFor: { target in
        switch target {
        case .framework:
            return [
                ExternalDependency.flow,
                ExternalDependency.form,
                ExternalDependency.presentation,
                ExternalDependency.dynamiccolor,
                ExternalDependency.markdownkit,
                ExternalDependency.disk,
            ]
        default:
            return []
        }
    },
    sdks: ["UIKit.framework"],
    includesGraphQL: true
)
