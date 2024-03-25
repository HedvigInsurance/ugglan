import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Home",
    targets: Set([.framework]),
    projects: ["hCore", "hCoreUI", "TravelCertificate", "TerminateContracts", "Payment"],
    sdks: [],
    includesGraphQL: true
)
