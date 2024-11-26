import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Payment",
    targets: Set([.framework, .tests, .example]),
    projects: ["hCore", "hCoreUI", "Contracts", "Forever"],
    dependencies: ["CoreDependencies", "ResourceBundledDependencies"],
    sdks: [],
    includesGraphQL: true
)
