import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "SubmitClaimChat",
    targets: Set([.framework, .example, .tests]),
    projects: ["hCore", "hCoreUI", "Claims"],
    sdks: [],
    exampleScripts: [
        // Embeds RiveRuntime into the example app (see scripts/example-post-build-action.sh).
        .post(
            path: "../../scripts/example-post-build-action.sh",
            arguments: [],
            name: "Embed RiveRuntime",
            basedOnDependencyAnalysis: false
        )
    ]
)
