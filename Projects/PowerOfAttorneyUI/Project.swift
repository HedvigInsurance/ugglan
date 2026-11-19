import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "PowerOfAttorneyUI",
    targets: Set([.framework]),
    projects: ["hCore", "hCoreUI", "ContractsCore", "EditStakeholdersCore", "PowerOfAttorneyCore"],
    sdks: []
)
