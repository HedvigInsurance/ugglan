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
    dependencies: ["hCore"],
    sdks: ["UIKit.framework"],
    includesGraphQL: true
)
