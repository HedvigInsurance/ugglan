import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "SubmitClaim",
    targets: Set([.framework, .tests, .example]),
    projects: ["hCore", "hCoreUI", "Claims"],
    sdks: []
)
