import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "MoveFlow",
    targets: Set([.framework]),
    projects: ["hCore", "hCoreUI", "hGraphQL", "Contracts"],
    dependencies: ["CoreDependencies", "ResourceBundledDependencies"],
    sdks: [],
    includesGraphQL: true
)
