import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "ExampleUtil",
    targets: Set([.framework]),
    projects: ["hCore", "hCoreUI"],
    dependencies: ["CoreDependencies", "DevDependencies"],
    sdks: [],
    includesGraphQL: false
)
