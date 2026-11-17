import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Payment",
    targets: Set([.framework, .tests]),
    projects: ["hCore", "hCoreUI", "Forever", "CampaignCore", "CampaignUI"],
    dependencies: ["CoreDependencies"],
    sdks: []
)
