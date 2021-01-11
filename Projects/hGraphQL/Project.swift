import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "hGraphQL",
    targets: Set([
        .framework,
    ]),
    dependencies: [],
    sdks: [],
    includesGraphQL: true
)
