import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Onboarding",
    targets: Set([.framework, .tests]),
    projects: [
        "hCore", "hCoreUI", "ContractsCore", "ContractsUI", "EditStakeholdersCore", "EditStakeholdersUI", "Payment",
        "Forever", "CrossSellCore", "CrossSellUI", "Profile",
    ],
    sdks: []
)
