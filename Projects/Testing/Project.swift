import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.framework(
    name: "Testing",
    targets: Set([.framework]),
    sdks: ["XCTest.framework"]
)
