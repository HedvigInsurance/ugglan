import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Contracts",
    targets: Set([.framework, .frameworkResources, .tests, .example]),
    projects: ["hCore", "hCoreUI", "TerminateContracts", "EditCoInsured"],
    sdks: [],
    includesGraphQL: false
)
