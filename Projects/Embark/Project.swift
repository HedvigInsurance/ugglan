import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Embark",
    externalDependencies: [.apollo, .flow, .snapkit, .form, .presentation],
    dependencies: ["hCore", "hCoreUI"],
    includesGraphQL: true
)
