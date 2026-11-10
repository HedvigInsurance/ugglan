import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "ChangeTierUI",
    targets: Set([.framework, .tests]),
    projects: ["hCore", "hCoreUI", "ChangeTierCore", "CrossSellCore"],
    sdks: []
)
