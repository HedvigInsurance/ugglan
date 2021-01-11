import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "hCoreUI",
    targets: Set([
        .framework,
        .frameworkResources,
        .tests,
        .example,
        .testing,
    ]),
    projects: ["hCore"],
    sdks: ["UIKit.framework"],
    includesGraphQL: true
)
