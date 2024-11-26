import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "ChangeTier",
    targets: Set([.framework, .example, .tests, .swift6]),
    projects: ["hCore", "hCoreUI"],
    sdks: [],
    includesGraphQL: true
)
