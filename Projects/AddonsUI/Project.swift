import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "AddonsUI",
    targets: Set([.framework, .example, .tests]),
    projects: ["hCore", "hCoreUI", "AddonsCore"],
    sdks: []
)
