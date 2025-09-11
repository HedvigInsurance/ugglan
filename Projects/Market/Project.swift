import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Market",
    targets: Set([.framework, .frameworkResources]),
    projects: ["hCore", "hCoreUI"],
    sdks: []
)
