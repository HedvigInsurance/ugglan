import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Payment",
    targets: Set([
        .framework,
        .tests,
        .example,
        .testing,
    ]),
    externalDependencies: [.apollo, .flow, .flowfeedback, .snapkit, .form, .presentation, .adyen],
    dependencies: ["hCore", "hCoreUI"],
    sdks: [],
    includesGraphQL: true
)
