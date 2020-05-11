import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "hCore",
    targets: Set([
       .framework,
       .tests,
       .example,
       .testing
    ]),
    externalDependencies: [.flow, .dynamiccolor],
    dependencies: [],
    sdks: [],
    includesGraphQL: true
)
