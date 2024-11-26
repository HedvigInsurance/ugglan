import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Market",
    targets: Set([.framework, .frameworkResources, .swift6]),
    projects: ["hCore", "hCoreUI"],
    sdks: [],
    includesGraphQL: true
)
