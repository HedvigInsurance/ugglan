import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "EditCoInsuredShared",
    targets: Set([.framework]),
    projects: ["hCore", "hCoreUI"],
    sdks: [],
    includesGraphQL: true
)
