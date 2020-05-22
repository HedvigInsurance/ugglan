import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "hCore",
    targets: Set([
        .framework,
        .frameworkResources,
        .tests,
        .example,
        .testing,
    ]),
    externalDependencies: [.flow, .dynamiccolor, .presentation, .snapkit, .apollo, .form],
    dependencies: [],
    sdks: [],
    includesGraphQL: true
)
