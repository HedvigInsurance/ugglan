import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "AuthenticationCore",
    targets: Set([
        .framework,
        .tests,
        .example,
    ]),
    projects: [
        "hCore"
    ],
    sdks: []
)
