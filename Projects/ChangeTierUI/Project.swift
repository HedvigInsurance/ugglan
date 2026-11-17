import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "ChangeTierUI",
    targets: Set([.framework, .tests]),
    projects: ["hCore", "hCoreUI", "ChangeTierCore", "CrossSellCore"],
    sdks: [],
    sharedTestSources: [
        "Projects/ChangeTierCore/Tests/MockData.swift",
        "Projects/ChangeTierCore/Tests/TierFixtures.swift",
    ]
)
