import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "hCoreUI",
    targets: Set([
        .framework,
        .frameworkResources,
        .tests,
        .example,
        .testing,
    ]),
    externalDependencies: [
        .flow,
        .form,
        .snapkit,
        .presentation,
        .dynamiccolor,
        .flowfeedback,
        .markdownkit,
        .kingfisher,
    ],
    dependencies: ["hCore"],
    sdks: ["UIKit.framework"],
    includesGraphQL: true
)
