import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Chat",
    targets: Set([.framework, .example, .tests, .swift6]),
    projects: ["hCore", "hCoreUI", "Contracts"],
    sdks: [],
    includesGraphQL: true
)
