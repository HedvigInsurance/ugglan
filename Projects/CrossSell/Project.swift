import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "CrossSell",
    targets: Set([.framework, .tests, .example]),
    projects: ["hCore", "hCoreUI", "Addons"],
    sdks: []
)
