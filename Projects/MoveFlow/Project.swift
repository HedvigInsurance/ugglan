import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "MoveFlow",
    targets: Set([.framework, .tests, .example, .testing]),
    projects: ["hCore", "hCoreUI", "hGraphQL"],
    dependencies: ["CoreDependencies", "ResourceBundledDependencies"],
    sdks: [],
    includesGraphQL: true
)
