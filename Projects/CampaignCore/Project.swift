import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "CampaignCore",
    targets: Set([.framework, .example, .tests]),
    projects: ["hCore"],
    sdks: []
)
