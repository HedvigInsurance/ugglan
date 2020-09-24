import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "TestingUtil",
    targets: Set([
        .framework,
    ]),
    externalDependencies: [.apollo],
    dependencies: ["hCore"],
    sdks: [],
    includesGraphQL: false
)
