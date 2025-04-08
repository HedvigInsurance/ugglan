import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Forever",
    targets: Set([.framework, .tests, .example]),
    projects: ["hCore", "hCoreUI"],
    sdks: []
)
