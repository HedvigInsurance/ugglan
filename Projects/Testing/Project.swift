import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Testing",
    targets: Set([.framework]),
    projects: ["hCoreUI", "hCore"],
    externalDependenciesFor: { target in
        switch target {
        case .framework:
            return [
                ExternalDependency.snapshottesting,
                ExternalDependency.flow,
                ExternalDependency.form
            ]
        default:
            return []
        }
    },
    sdks: ["XCTest.framework"]
)
