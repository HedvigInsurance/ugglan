import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Chat",
    targets: Set([.framework, .example, .tests]),
    projects: ["hCore", "hCoreUI", "Contracts"],
    sdks: []
)
