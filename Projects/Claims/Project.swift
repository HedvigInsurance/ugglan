import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Claims",
    targets: Set([.framework]),
    projects: ["hCore", "hCoreUI", "Contracts", "Home"],
    sdks: [],
    includesGraphQL: true
)
