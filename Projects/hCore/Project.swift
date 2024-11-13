import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "hCore",
    targets: Set([.framework, .frameworkResources, .swift6]),
    projects: ["hGraphQL"],
    sdks: [],
    includesGraphQL: false
)
