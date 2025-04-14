import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Claims",
    targets: Set([.framework, .tests, .example]),
    projects: ["hCore", "hCoreUI", "Contracts", "Chat", "Payment"],
    sdks: []
)
