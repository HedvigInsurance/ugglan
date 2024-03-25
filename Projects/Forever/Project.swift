import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Forever",
    targets: Set([.framework]),
    projects: ["hCore", "hCoreUI"],
    sdks: [],
    includesGraphQL: true
)
