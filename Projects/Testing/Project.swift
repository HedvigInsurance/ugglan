import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Testing",
    targets: Set([.framework, .tests, .example]),
    projects: ["hCoreUI", "hCore"],
    dependencies: ["CoreDependencies", "TestDependencies"],
    sdks: ["XCTest"]
)
