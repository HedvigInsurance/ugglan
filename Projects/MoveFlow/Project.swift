import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "MoveFlow",
    targets: Set([.framework, .tests]),
    projects: ["hCore", "hCoreUI", "CrossSellCore", "ChangeTierCore", "ChangeTierUI"],
    dependencies: ["CoreDependencies"],
    sdks: []
)
