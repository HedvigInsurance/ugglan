import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "hCore",
    targets: Set([.framework, .frameworkResources, .tests]),
    projects: ["hGraphQL"],
    sdks: []
)
