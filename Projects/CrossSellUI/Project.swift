import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "CrossSellUI",
    targets: Set([.framework]),
    projects: ["hCore", "hCoreUI", "AddonsCore", "CrossSellCore"],
    sdks: []
)
