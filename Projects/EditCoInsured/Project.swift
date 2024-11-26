import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "EditCoInsured",
    targets: Set([.framework, .example, .tests, .swift6]),
    projects: ["hCore", "hCoreUI", "EditCoInsuredShared"],
    sdks: [],
    includesGraphQL: false
)
