import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "ContractsUI",
    targets: Set([.framework]),
    projects: [
        "hCore", "hCoreUI", "ContractsCore", "TerminateContractsCore", "TerminateContractsUI", "EditStakeholdersCore",
        "EditStakeholdersUI", "ChangeTierUI", "AddonsCore", "AddonsUI", "CrossSellCore", "CrossSellUI",
    ],
    sdks: []
)
