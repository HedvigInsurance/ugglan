import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Forever",
    targets: Set([
        .framework,
        .frameworkResources,
        .tests,
        .example,
        .testing,
    ]),
    externalDependencies: [
        .flow,
        .presentation,
        .form,
    ],
    dependencies: [
        "hCore",
        "hCoreUI",
    ],
    sdks: [],
    includesGraphQL: true
)
