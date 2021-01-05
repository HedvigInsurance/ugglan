import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "hGraphQL",
    targets: Set([
        .framework,
    ]),
    externalDependencies: [.apollo, .disk, .flow],
    dependencies: [],
    sdks: [],
    includesGraphQL: true
)
