import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "ExampleUtil",
    targets: Set([
        .framework,
    ]),
    dependencies: [
        "hCore",
        "hCoreUI",
        "DevDependencies",
    ],
    sdks: [],
    includesGraphQL: false
)
