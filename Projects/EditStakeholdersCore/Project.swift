import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "EditStakeholdersCore",
    targets: Set([.framework]),
    projects: ["hCore"],
    sdks: []
)
