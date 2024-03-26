import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Contracts",
    targets: Set([.framework]),
    projects: ["hCore", "hCoreUI", "EditCoInsured"],
    sdks: [],
    includesGraphQL: false
)
