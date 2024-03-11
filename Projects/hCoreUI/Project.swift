import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "hCoreUI",
    targets: Set([.framework, .frameworkResources, .tests, .example, .testing, .generateAssets]),
    projects: ["hCore"],
    sdks: ["UIKit"],
    includesGraphQL: true
)
