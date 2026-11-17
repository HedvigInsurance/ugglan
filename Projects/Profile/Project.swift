import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Profile",
    targets: Set([.framework, .tests]),
    projects: [
        "hCore", "hCoreUI", "Home", "Claims", "ContractsCore", "TravelCertificateUI", "Market", "AuthenticationCore",
        "AuthenticationUI", "InsuranceEvidence",
    ],
    sdks: []
)
