import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Home",
    targets: Set([.framework]),
    projects: ["hCore", "hCoreUI", "TravelCertificate", "Payment"],
    sdks: [],
    includesGraphQL: true
)
