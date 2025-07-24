import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "EditCoInsured",
    targets: Set([.framework, .example, .tests]),
    projects: ["hCore", "hCoreUI"],
    sdks: []
)
