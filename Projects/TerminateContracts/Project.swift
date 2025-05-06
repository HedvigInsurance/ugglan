import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "TerminateContracts",
    targets: Set([.framework, .tests, .example]),
    projects: ["hCore", "hCoreUI", "ChangeTier"],
    sdks: []
)
