import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Profile",
    targets: Set([.framework, .tests]),
    projects: [
        "hCore", "hCoreUI", "Home", "Claims", "Contracts", "TravelCertificate", "Market", "AuthenticationCore",
        "AuthenticationUI", "InsuranceEvidence",
    ],
    sdks: []
)
