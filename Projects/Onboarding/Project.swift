import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Onboarding",
    targets: Set([.framework, .example, .tests]),
    projects: ["hCore", "hCoreUI", "Contracts", "EditStakeholders", "Payment", "Forever", "CrossSell"],
    sdks: []
)
