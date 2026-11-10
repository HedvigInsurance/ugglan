import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Contracts",
    targets: Set([.framework, .tests]),
    projects: [
        "hCore", "hCoreUI", "TerminateContractsCore", "TerminateContractsUI", "EditStakeholdersCore",
        "EditStakeholdersUI", "ChangeTier", "AddonsCore", "AddonsUI", "CrossSellCore", "CrossSellUI",
    ],
    sdks: []
)
