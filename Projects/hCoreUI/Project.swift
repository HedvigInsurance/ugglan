import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "hCoreUI",
    targets: Set([.framework, .frameworkResources]),
    projects: ["hCore"]
)
