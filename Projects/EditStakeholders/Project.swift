import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "EditStakeholders",
    targets: Set([.framework, .example, .tests]),
    projects: ["hCore", "hCoreUI", "CrossSell"],
    sdks: []
)
