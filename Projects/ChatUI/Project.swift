import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "ChatUI",
    targets: Set([.framework, .tests]),
    projects: ["hCore", "hCoreUI", "ChatCore", "AddonsCore", "ContractsCore", "CrossSellCore", "CrossSellUI"],
    sdks: []
)
