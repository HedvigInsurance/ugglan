import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Campaign",
    targets: Set([.framework, .example, .tests]),
    projects: ["hCore", "hCoreUI", "Forever"],
    sdks: []
)
