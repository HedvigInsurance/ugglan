import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "TestingUtil",
    targets: Set([
        .framework,
    ]),
    dependencies: ["hCore"],
    sdks: [],
    includesGraphQL: false
)
