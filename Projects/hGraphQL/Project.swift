import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "hGraphQL",
    targets: Set([
        .framework,
    ]),
    externalDependencies: [.apollo],
    dependencies: [],
    sdks: [],
    includesGraphQL: true
)
