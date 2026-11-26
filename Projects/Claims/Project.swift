import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Claims",
    targets: Set([.framework, .tests]),
    projects: ["hCore", "hCoreUI", "ChatCore", "Payment", "CrossSellCore"],
    sdks: []
)
