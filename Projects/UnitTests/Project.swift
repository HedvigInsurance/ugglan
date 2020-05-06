import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "UnitTests",
    targets: Set([.framework]),
    sdks: ["XCTest.framework"]
)
