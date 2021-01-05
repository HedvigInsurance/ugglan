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
    externalDependencies: [.apollo, .flow, .snapkit, .form, .presentation, .adyen, .ease],
    dependencies: ["hCore", "hCoreUI"],
    sdks: [],
    includesGraphQL: true
)
