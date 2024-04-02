import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "TravelCertificateShared",
    targets: Set([.framework]),
    projects: ["hCore", "hCoreUI", "Contracts"],
    sdks: [],
    includesGraphQL: true
)
