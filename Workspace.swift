import ProjectDescription

let testableTargets = [
    TestableTarget(target: .project(path: "Projects/App", target: "AppTests")),
    TestableTarget(target: .project(path: "Projects/Embark", target: "EmbarkTests")),
    TestableTarget(target: .project(path: "Projects/hCore", target: "hCoreTests")),
    TestableTarget(target: .project(path: "Projects/hCoreUI", target: "hCoreUITests")),
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
    ],
    schemes: [
        Scheme(name: "WorkspaceTests",
               shared: true,
               buildAction: nil,
               testAction: TestAction(targets: testableTargets, arguments: Arguments(environment: ["SNAPSHOT_ARTIFACTS": "/tmp/__SnapshotFailures__"], launch: [:])),
               runAction: nil,
               archiveAction: nil),
        Scheme(name: "WorkspaceTests Record",
               shared: true,
               buildAction: nil,
               testAction: TestAction(targets: testableTargets, arguments: Arguments(environment: ["SNAPSHOT_ARTIFACTS": "/tmp/__SnapshotFailures__", "SNAPSHOT_TEST_MODE": "RECORD"], launch: [:])),
               runAction: nil,
               archiveAction: nil),
    ]
)
