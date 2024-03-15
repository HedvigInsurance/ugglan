import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Payment",
    targets: Set([.framework]),
    projects: ["hCore", "hCoreUI", "Contracts"],
    dependencies: ["CoreDependencies", "ResourceBundledDependencies", "Forever"],
    sdks: [],
    includesGraphQL: true
)
