import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "InsuranceEvidence",
    targets: Set([.framework, .example]),
    projects: ["hCore", "hCoreUI"],
    sdks: []
)
