import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "MoveFlowCore",
    targets: Set([.framework]),
    projects: ["hCore", "ChangeTierCore"],
    sdks: []
)
