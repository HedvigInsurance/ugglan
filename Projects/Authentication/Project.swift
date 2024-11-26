import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Authentication",
    targets: Set([
        .framework,
        .tests,
        .example,
        .testing,
        .swift6,
    ]),
    projects: [
        "hCore",
        "hCoreUI",
    ],
    sdks: [],
    includesGraphQL: false
)
