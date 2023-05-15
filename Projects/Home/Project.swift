import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Home",
    targets: Set([.framework, .frameworkResources, .tests, .example, .testing]),
    projects: ["hCore", "hCoreUI", "Claims", "Contracts"],
    sdks: [],
    includesGraphQL: true
)
