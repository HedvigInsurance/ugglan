import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "ExampleUtil",
    targets: Set([
       .framework
    ]),
    externalDependencies: [
        .flow,
        .form,
        .presentation,
        .runtime
    ],
    dependencies: [
        "hCore",
        "hCoreUI"
    ],
    sdks: [],
    includesGraphQL: false
)
