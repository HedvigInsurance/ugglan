import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "EditCoInsured",
    targets: Set([.framework]),
    projects: ["hCore", "hCoreUI"],
    sdks: [],
    includesGraphQL: false
)
