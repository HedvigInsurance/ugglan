import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
  name: "TestingUtil",
  targets: Set([.framework]),
  projects: ["hCore"],
  sdks: [],
  includesGraphQL: false
)
