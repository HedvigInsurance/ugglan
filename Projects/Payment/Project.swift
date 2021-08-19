import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Payment",
    targets: Set([.framework, .tests, .example, .testing]),
    projects: ["hCore", "hCoreUI"],
    externalDependenciesFor: { target in
        switch target {
        case .framework:
            return [
                ExternalDependency.adyen
            ]
        default:
            return []
        }
    },
    sdks: [],
    includesGraphQL: true
)
