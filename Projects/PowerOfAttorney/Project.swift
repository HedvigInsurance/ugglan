import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "PowerOfAttorney",
    targets: Set([.framework]),
    projects: ["hCore", "hCoreUI"],
    sdks: []
)
