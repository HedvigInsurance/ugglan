import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Authentication",
    targets: Set([
        .framework,
        .tests,
        .example,
        .testing,
    ]),
    projects: [
        "hCore",
        "hCoreUI",
    ],
    sdks: []
)
