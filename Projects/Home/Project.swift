import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Home",
    targets: Set([.framework, .tests, .example]),
    projects: ["hCore", "hCoreUI", "TravelCertificate", "TerminateContracts", "Payment", "Chat", "Claims"],
    sdks: []
)
