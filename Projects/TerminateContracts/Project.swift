import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "TerminateContracts",
    targets: Set([.framework, .frameworkResources, .tests, .example]),
    projects: ["hCore", "hCoreUI"],
    sdks: [],
    includesGraphQL: false
)
