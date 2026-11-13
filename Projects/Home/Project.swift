import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Home",
    targets: Set([.framework, .tests]),
    projects: [
        "hCore", "hCoreUI", "AddonsCore", "TravelCertificate", "TerminateContractsCore", "TerminateContractsUI",
        "Payment", "Chat", "Claims", "SubmitClaimChat", "CrossSellCore", "CrossSellUI", "EditStakeholdersCore",
        "EditStakeholdersUI",
    ],
    sdks: []
)
