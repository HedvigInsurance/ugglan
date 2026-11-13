import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Contracts",
    targets: Set([.framework, .tests]),
    projects: [
        "hCore", "hCoreUI", "TerminateContracts", "EditStakeholdersCore", "EditStakeholdersUI", "ChangeTier",
        "AddonsCore", "AddonsUI", "CrossSellCore", "CrossSellUI",
    ],
    sdks: []
)
