import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "TravelCertificateUI",
    targets: Set([.framework, .tests]),
    projects: [
        "hCore", "hCoreUI", "TravelCertificateCore", "AddonsCore", "AddonsUI", "ContractsCore", "EditStakeholdersCore",
        "EditStakeholdersUI",
    ],
    sdks: []
)
