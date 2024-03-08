import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "TerminateContracts",
    targets: Set([.framework]),
    projects: ["hCore", "hCoreUI"],
    sdks: [],
    includesGraphQL: false
)
