import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "TravelCertificate",
    targets: Set([.framework, .tests]),
    projects: [
        "hCore", "hCoreUI", "AddonsCore", "AddonsUI", "Contracts", "EditStakeholdersCore", "EditStakeholdersUI",
    ],
    sdks: []
)
