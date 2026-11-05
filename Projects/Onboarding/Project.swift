import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Onboarding",
    targets: Set([.framework, .tests]),
    projects: ["hCore", "hCoreUI", "Contracts", "EditStakeholders", "Payment", "Forever", "CrossSell", "Profile"],
    sdks: []
)
