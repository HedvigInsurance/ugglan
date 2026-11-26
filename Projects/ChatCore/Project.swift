import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "ChatCore",
    targets: Set([.framework]),
    projects: ["hCore"],
    sdks: []
)
