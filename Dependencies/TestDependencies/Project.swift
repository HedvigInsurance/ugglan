import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.dependenciesFramework(
    name: "TestDependencies",
    externalDependencies: ExternalDependencies.allCases.filter(\.isTestDependency),
    sdks: ["XCTest"]
)
