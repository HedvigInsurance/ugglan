import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
	name: "Payment",
	targets: Set([.framework, .tests, .example, .testing]),
	projects: ["hCore", "hCoreUI"],
	sdks: [],
	includesGraphQL: true
)
