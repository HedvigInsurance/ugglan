import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Contracts",
    targets: Set([.framework, .tests, .example]),
    projects: ["hCore", "hCoreUI", "TerminateContracts", "EditCoInsuredShared", "ChangeTier"],
    sdks: [],
    includesGraphQL: false
)
