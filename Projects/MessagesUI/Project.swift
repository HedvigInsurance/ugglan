import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "MessagesUI",
    targets: Set([.framework]),
    projects: ["hCore", "hCoreUI", "MessagesCore"],
    sdks: []
)
