import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Home",
    targets: Set([.framework, .tests, .example]),
    projects: [
        "hCore", "hCoreUI", "AddonsCore", "TravelCertificate", "TerminateContracts", "Payment", "Chat", "Claims",
        "SubmitClaimChat",
    ],
    sdks: []
)
