import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Home",
    targets: Set([
        .framework,
        .frameworkResources,
        .tests,
        .example,
        .testing,
    ]),
    dependencies: ["hCore", "hCoreUI"],
    sdks: [],
    includesGraphQL: true
)
