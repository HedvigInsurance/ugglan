import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Forever",
    targets: Set([.framework, .tests]),
    projects: ["hCore", "hCoreUI"],
    sdks: []
)
