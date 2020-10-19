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
    dependencies: ["hCore", "hCoreUI"],
    sdks: [],
    includesGraphQL: true
)
