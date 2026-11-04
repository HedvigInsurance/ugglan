import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "CampaignCore",
    targets: Set([.framework, .tests]),
    projects: ["hCore"],
    sdks: []
)
