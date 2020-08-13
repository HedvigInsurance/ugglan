import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Home",
    targets: Set([
       .framework,
       .frameworkResources,
       .tests,
       .example,
       .testing
    ]),
    externalDependencies: [.apollo, .flow, .presentation],
    dependencies: ["hCore", "hCoreUI"],
    sdks: [],
    includesGraphQL: true
)
