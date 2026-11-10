import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "MoveFlowUI",
    targets: Set([.framework, .tests]),
    projects: ["hCore", "hCoreUI", "MoveFlowCore", "CrossSellCore", "ChangeTierCore", "ChangeTierUI"],
    dependencies: ["CoreDependencies"],
    sdks: []
)
