import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Profile",
    targets: Set([.framework, .tests]),
    projects: [
        "hCore", "hCoreUI", "Home", "Claims", "ContractsCore", "TravelCertificate", "Market", "AuthenticationCore",
        "AuthenticationUI", "InsuranceEvidence", "PowerOfAttorney",
    ],
    sdks: []
)
