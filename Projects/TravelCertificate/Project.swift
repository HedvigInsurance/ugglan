import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "TravelCertificate",
    targets: Set([.framework, .tests, .example, .swift6]),
    projects: ["hCore", "hCoreUI", "Contracts", "EditCoInsuredShared"],
    sdks: [],
    includesGraphQL: false
)
