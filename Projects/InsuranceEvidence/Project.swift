import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "InsuranceEvidence",
    targets: Set([.framework, .tests]),
    projects: ["hCore", "hCoreUI"],
    sdks: []
)
