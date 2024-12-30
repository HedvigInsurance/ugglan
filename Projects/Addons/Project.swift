import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Addons",
    targets: Set([.framework, .example, .tests]),
    projects: ["hCore", "hCoreUI"],
    sdks: [],
    includesGraphQL: true
)
