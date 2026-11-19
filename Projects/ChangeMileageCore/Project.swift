import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "ChangeMileageCore",
    targets: Set([.framework, .tests]),
    projects: ["hCore"],
    sdks: []
)
