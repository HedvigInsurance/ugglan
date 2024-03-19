import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Profile",
    targets: Set([.framework]),
    projects: ["hCore", "hCoreUI", "Home", "Claims", "Contracts", "TravelCertificate"],
    sdks: [],
    includesGraphQL: false
)
