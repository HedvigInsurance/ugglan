import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Chat",
    targets: Set([.framework, .frameworkResources]),
    projects: ["hCore", "hCoreUI", "Contracts"],
    sdks: [],
    includesGraphQL: true
)
