import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "TravelCertificate",
    targets: Set([.framework]),
    projects: ["hCore", "hCoreUI", "Contracts", "EditCoInsuredShared"],
    sdks: [],
    includesGraphQL: false
)
