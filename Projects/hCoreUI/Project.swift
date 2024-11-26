import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "hCoreUI",
    targets: Set([.framework, .frameworkResources, .generateAssets, .swift6]),
    projects: ["hCore"],
    includesGraphQL: true
)
