import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "hInterfaces",
    targets: Set([.framework, .frameworkResources, .tests, .example, .testing]),
    projects: ["hGraphQL"],
    sdks: [],
    includesGraphQL: false
)
