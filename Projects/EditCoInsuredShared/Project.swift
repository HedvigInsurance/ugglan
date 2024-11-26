import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "EditCoInsuredShared",
    targets: Set([.framework, .swift6]),
    projects: ["hCore", "hCoreUI"],
    sdks: [],
    includesGraphQL: true
)
