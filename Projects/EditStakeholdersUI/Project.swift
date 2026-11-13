import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "EditStakeholdersUI",
    targets: Set([.framework, .tests]),
    projects: ["hCore", "hCoreUI", "EditStakeholdersCore"],
    sdks: []
)
