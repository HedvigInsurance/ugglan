import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "SubmitClaimChat",
    targets: Set([.framework, .tests, .testHost]),
    projects: ["hCore", "hCoreUI", "Claims"],
    sdks: []
)
