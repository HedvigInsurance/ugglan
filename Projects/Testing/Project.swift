import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Testing",
    targets: Set([.framework]),
    dependencies: ["hCoreUI", "hCore"],
    sdks: ["XCTest.framework"]
)
