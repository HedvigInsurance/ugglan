import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "ContractsCore",
    targets: Set([.framework, .tests]),
    projects: ["hCore", "AddonsCore", "EditStakeholdersCore", "TerminateContractsCore"],
    sdks: []
)
