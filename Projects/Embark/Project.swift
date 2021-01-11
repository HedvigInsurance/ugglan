import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Embark",
    dependencies: ["hCore", "hCoreUI"],
    includesGraphQL: true
)
