import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "TravelCertificate",
    targets: Set([.framework]),
    projects: ["hCore", "hCoreUI", "Contracts", "TravelCertificateShared"],
    sdks: [],
    includesGraphQL: false
)
