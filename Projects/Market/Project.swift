import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Market",
    targets: Set([
        .framework,
        .frameworkResources,
        .tests,
        .example,
        .testing,
    ]),
    externalDependencies: [.apollo, .flow, .presentation, .snapkit],
    dependencies: ["hCore", "hCoreUI"],
    sdks: [],
    includesGraphQL: true
)
