import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "TerminateContractsUI",
    targets: Set([.framework, .tests]),
    projects: ["hCore", "hCoreUI", "TerminateContractsCore", "ChangeTier"],
    sdks: []
)
