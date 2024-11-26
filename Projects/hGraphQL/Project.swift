import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "hGraphQL",
    targets: Set([.framework, .swift6]),
    projects: [],
    sdks: [],
    includesGraphQL: true
)
