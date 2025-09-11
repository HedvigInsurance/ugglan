import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "InsuranceEvidence",
    targets: Set([.framework, .example, .tests]),
    projects: ["hCore", "hCoreUI"],
    sdks: []
)
