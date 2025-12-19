import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "SubmitClaimChat",
    targets: Set([.framework, .example, .tests]),
    projects: ["hCore", "hCoreUI", "Claims"],
    sdks: []
)
