import ProjectDescription
import ProjectDescriptionHelpers

let testableTargets = [
    TestableTarget(target: .project(path: "Projects/App", target: "AppTests"), parallelizable: true),
    TestableTarget(target: .project(path: "Projects/Embark", target: "EmbarkTests"), parallelizable: true),
    TestableTarget(target: .project(path: "Projects/hCore", target: "hCoreTests"), parallelizable: true),
    TestableTarget(target: .project(path: "Projects/hCoreUI", target: "hCoreUITests"), parallelizable: true),
    TestableTarget(target: .project(path: "Projects/Forever", target: "ForeverTests"), parallelizable: true),
    TestableTarget(target: .project(path: "Projects/ExampleUtil", target: "ExampleUtilTests"), parallelizable: true),
    TestableTarget(target: .project(path: "Projects/Contracts", target: "ContractsTests"), parallelizable: true),
    TestableTarget(target: .project(path: "Projects/Home", target: "HomeTests"), parallelizable: true)
]

let workspace = Workspace(
    name: "Ugglan",
    projects: [
        "Projects/App",
        "Projects/Codegen",
        "Projects/Embark",
        "Projects/Testing",
        "Projects/hCore",
        "Projects/hCoreUI",
        "Projects/hGraphQL",
        "Projects/Forever",
        "Projects/ExampleUtil",
        "Projects/Contracts",
        "Projects/Home",
    ],
    schemes: [
        Scheme(name: "WorkspaceApps",
               shared: true,
               buildAction: BuildAction(targets: [
                .project(path: "Projects/App", target: "Ugglan"),
                .project(path: "Projects/Embark", target: "EmbarkExample"),
                .project(path: "Projects/Forever", target: "ForeverExample")
               ]),
               testAction: nil,
               runAction: nil,
               archiveAction: nil),
        Scheme(name: "WorkspaceTests",
               shared: true,
               buildAction: nil,
               testAction: TestAction(
                   targets: testableTargets,
                   arguments: Arguments(environment: ["SNAPSHOT_ARTIFACTS": "/tmp/__SnapshotFailures__"], launch: ["-UIPreferredContentSizeCategoryName": true, "UICTContentSizeCategoryM": true]),
                   coverage: true
               ),
               runAction: nil,
               archiveAction: nil),
        Scheme(name: "WorkspaceTests Record",
               shared: true,
               buildAction: nil,
               testAction: TestAction(
                   targets: testableTargets,
                   arguments: Arguments(environment: ["SNAPSHOT_ARTIFACTS": "/tmp/__SnapshotFailures__", "SNAPSHOT_TEST_MODE": "RECORD"], launch: ["-UIPreferredContentSizeCategoryName": true, "UICTContentSizeCategoryM": true]),
                   coverage: true
               ),
               runAction: nil,
               archiveAction: nil),
    ]
)
