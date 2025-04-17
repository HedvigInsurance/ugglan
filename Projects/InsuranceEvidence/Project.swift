import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "InsuranceEvidence",
    targets: Set([.framework, .tests, .example]),
    projects: ["hCore", "hCoreUI"],
    sdks: [],
    includesGraphQL: true
)
