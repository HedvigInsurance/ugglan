import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "TerminateContractsCore",
    targets: Set([.framework, .tests]),
    projects: ["hCore"],
    sdks: []
)
