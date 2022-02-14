import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Claims",
    targets: Set([.framework, .frameworkResources, .example]),
    projects: ["hCore", "hCoreUI"],
    sdks: [],
    includesGraphQL: true
)
