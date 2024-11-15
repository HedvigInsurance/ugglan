import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Home",
    targets: Set([.framework, .tests, .example, .swift6]),
    projects: ["hCore", "hCoreUI", "TravelCertificate", "TerminateContracts", "Payment", "Chat"],
    sdks: [],
    includesGraphQL: true
)
