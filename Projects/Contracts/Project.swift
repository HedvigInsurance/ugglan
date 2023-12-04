import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Contracts",
    targets: Set([.framework, .frameworkResources, .example]),
    projects: ["hCore", "hCoreUI", "TerminateContracts", "EditCoInsured"],
    sdks: [],
    includesGraphQL: false
)
