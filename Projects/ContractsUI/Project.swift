import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "ContractsUI",
    targets: Set([.framework]),
    projects: [
        "hCore", "hCoreUI", "ContractsCore", "TerminateContractsCore", "TerminateContractsUI", "EditStakeholdersCore",
        "EditStakeholdersUI", "ChangeTierUI", "ChangeMileageCore", "ChangeMileageUI", "AddonsCore", "AddonsUI", "CrossSellCore", "CrossSellUI",
    ],
    sdks: []
)
