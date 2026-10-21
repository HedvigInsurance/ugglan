import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "hCore",
    targets: Set([.framework, .frameworkResources, .tests]),
    // No hGraphQL: GraphQL-fragment conversions for hCore models live in App, so feature modules (and their
    // SwiftUI previews) don't link the generated GraphQL code.
    projects: [],
    sdks: []
)
