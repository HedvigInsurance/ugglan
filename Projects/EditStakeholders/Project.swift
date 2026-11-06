import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "EditStakeholders",
    targets: Set([.framework, .tests]),
    projects: ["hCore", "hCoreUI"],
    sdks: []
)
