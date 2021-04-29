import ProjectDescription

let config = Config(
    compatibleXcodeVersions: ["12.2", "12.3", "12.4", "12.5"],
    generationOptions: [
        .xcodeProjectName("\(.projectName)"),
        .organizationName("Hedvig AB"),
        .disableAutogeneratedSchemes,
        .disableSynthesizedResourceAccessors,
    ]
)
