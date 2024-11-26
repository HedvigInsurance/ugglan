import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Forever",
    targets: Set([.framework, .tests, .example, .swift6]),
    projects: ["hCore", "hCoreUI"],
    sdks: [],
    includesGraphQL: true
)
