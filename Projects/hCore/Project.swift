import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "hCore",
    targets: Set([.framework, .frameworkResources]),
    projects: ["hGraphQL"],
    sdks: []
)
