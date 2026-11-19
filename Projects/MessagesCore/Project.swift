import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "MessagesCore",
    targets: Set([.framework, .tests]),
    projects: ["hCore"],
    sdks: []
)
