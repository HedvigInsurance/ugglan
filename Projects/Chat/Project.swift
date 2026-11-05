import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Chat",
    targets: Set([.framework, .tests]),
    projects: ["hCore", "hCoreUI", "AddonsCore", "Contracts", "CrossSell"],
    sdks: []
)
