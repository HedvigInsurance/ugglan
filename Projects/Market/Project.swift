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
    externalDependencies: [.apollo, .flow, .presentation],
    dependencies: [],
    sdks: [],
    includesGraphQL: true
)
