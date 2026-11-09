import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "ChangeTier",
    targets: Set([.framework, .tests]),
    projects: ["hCore", "hCoreUI", "CrossSellCore"],
    sdks: []
)
