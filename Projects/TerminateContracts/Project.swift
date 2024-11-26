import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "TerminateContracts",
    targets: Set([.framework, .tests, .example, .swift6]),
    projects: ["hCore", "hCoreUI", "ChangeTier"],
    sdks: [],
    includesGraphQL: false
)
