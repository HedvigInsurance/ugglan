import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "AuthenticationUI",
    targets: Set([.framework]),
    projects: [
        "hCore",
        "hCoreUI",
        "AuthenticationCore",
    ],
    sdks: []
)
