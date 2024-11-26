import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Profile",
    targets: Set([.framework, .tests, .example, .swift6]),
    projects: ["hCore", "hCoreUI", "Home", "Claims", "Contracts", "TravelCertificate", "Market", "Authentication"],
    sdks: [],
    includesGraphQL: false
)
