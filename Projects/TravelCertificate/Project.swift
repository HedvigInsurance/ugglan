import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "TravelCertificate",
    targets: Set([.framework, .tests, .example]),
    projects: ["hCore", "hCoreUI", "AddonsCore", "AddonsUI", "Contracts", "EditStakeholders"],
    sdks: []
)
