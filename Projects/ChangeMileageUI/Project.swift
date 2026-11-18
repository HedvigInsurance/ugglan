import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "ChangeMileageUI",
    targets: Set([.framework, .tests]),
    projects: ["hCore", "hCoreUI", "ChangeMileageCore"],
    sdks: [],
    sharedTestSources: [
        "Projects/ChangeMileageCore/Tests/MockData.swift",
    ]
)
