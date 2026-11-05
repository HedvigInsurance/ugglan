import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "TerminateContracts",
    targets: Set([.framework, .tests]),
    projects: ["hCore", "hCoreUI", "ChangeTier"],
    sdks: []
)
