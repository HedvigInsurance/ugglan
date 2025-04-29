import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Profile",
    targets: Set([.framework, .tests, .example]),
    projects: [
        "hCore", "hCoreUI", "Home", "Claims", "Contracts", "TravelCertificate", "Market", "Authentication",
        "InsuranceEvidence",
    ],
    sdks: []
)
