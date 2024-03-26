import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Contracts",
    targets: Set([.framework]),
    projects: ["hCore", "hCoreUI", "TerminateContracts"],
    sdks: [],
    includesGraphQL: false
)
