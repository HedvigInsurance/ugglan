import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "ChangeTierCore",
    targets: Set([.framework, .tests]),
    projects: ["hCore"],
    sdks: []
)
