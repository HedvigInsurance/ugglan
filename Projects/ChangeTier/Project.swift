import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "ChangeTier",
    targets: Set([.framework, .example, .tests]),
    projects: ["hCore", "hCoreUI", "Addons", "CrossSell"],
    sdks: []
)
