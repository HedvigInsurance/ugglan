import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "TravelCertificateCore",
    targets: Set([.framework]),
    projects: ["hCore", "AddonsCore"],
    sdks: []
)
