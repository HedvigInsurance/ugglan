import ProjectDescription
import ProjectDescriptionHelpers

let workspace = Workspace(
    name: "Ugglan",
    projects: ["Projects/*", "Dependencies/*"],
    schemes: [
        Scheme.scheme(
            name: "Ugglan-Workspace",
            shared: true,
            buildAction: .buildAction(
                targets: [.project(path: "Projects/App", target: "Ugglan")]
            ),
            testAction: .testPlans(
                [
                    .relativeToRoot("TestPlans/Ugglan-Workspace.xctestplan")
                ]
            ),
            runAction: .runAction(
                executable: .project(path: "Projects/App", target: "Ugglan")
            )
        )
    ],
    generationOptions: .options(lastXcodeUpgradeCheck: .init(string: "1610"))
)
