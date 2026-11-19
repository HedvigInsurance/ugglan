import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "PowerOfAttorneyCore",
    targets: Set([.framework]),
    projects: ["hCore", "ContractsCore", "EditStakeholdersCore"],
    sdks: []
)
