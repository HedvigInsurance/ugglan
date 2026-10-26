import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.dependenciesFramework(
    name: "TestDependencies",
    externalDependencies: ExternalDependencies.allCases.filter(\.isTestDependency),
    // Testing.framework lives outside the SDK, and Tuist only adds its search paths for targets that
    // link XCTest. TestDependencies imports Testing directly, so it has to opt in itself.
    baseSettings: ["ENABLE_TESTING_SEARCH_PATHS": "YES"]
)
