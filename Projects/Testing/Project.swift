import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
	name: "Testing",
	targets: Set([.framework]),
	projects: ["hCoreUI", "hCore"],
	dependencies: ["CoreDependencies", "TestDependencies"],
	sdks: ["XCTest.framework"]
)
