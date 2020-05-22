import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Testing",
    targets: Set([.framework]),
    externalDependencies: [.flow],
    dependencies: ["hCoreUI", "hCore"],
    sdks: ["XCTest.framework"]
)
