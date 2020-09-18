import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Contracts",
    targets: Set([
        .framework,
        .frameworkResources,
        .tests,
        .example,
        .testing,
    ]),
    externalDependencies: [.apollo, .flow, .snapkit, .form, .presentation],
    dependencies: ["hCore", "hCoreUI"],
    sdks: [],
    includesGraphQL: true
)
