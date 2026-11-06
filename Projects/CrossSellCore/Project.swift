import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "CrossSellCore",
    targets: Set([.framework, .tests]),
    projects: ["hCore", "AddonsCore"],
    sdks: []
)
