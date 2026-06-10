import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "CampaignUI",
    targets: Set([.framework]),
    projects: ["hCore", "hCoreUI", "CampaignCore", "Forever"],
    sdks: []
)
