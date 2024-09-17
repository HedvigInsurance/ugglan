import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "SelectTier",
    targets: Set([.framework, .example, .tests]),
    projects: ["hCore", "hCoreUI"],
    sdks: [],
    includesGraphQL: true
)
