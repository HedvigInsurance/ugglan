import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
  name: "Forever",
  targets: Set([.framework, .frameworkResources, .tests, .example, .testing]),
  projects: ["hCore", "hCoreUI"],
  sdks: [],
  includesGraphQL: true
)
