import ProjectDescription
import ProjectDescriptionHelpers

let workspace = Workspace(
    name: "Ugglan",
    projects: ["Projects/*", "Dependencies/*"],
    generationOptions: .options(lastXcodeUpgradeCheck: .init(string: "1610"))
)
