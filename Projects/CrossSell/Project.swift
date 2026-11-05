import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "CrossSell",
    targets: Set([.framework, .tests]),
    projects: ["hCore", "hCoreUI", "AddonsCore"],
    sdks: []
)
