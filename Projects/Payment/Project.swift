import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Payment",
    targets: Set([.framework]),
    projects: ["hCore", "hCoreUI", "Contracts", "Forever"],
    dependencies: ["CoreDependencies", "ResourceBundledDependencies"],
    sdks: [],
    includesGraphQL: true
)
