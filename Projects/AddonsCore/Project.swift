import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "AddonsCore",
    targets: Set([.framework, .tests]),
    projects: ["hCore"],
    sdks: []
)
