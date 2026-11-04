import ProjectDescription

let tuist = Tuist(
    project: .tuist(
        // The committed project.xcproj (JSON) format can only be opened by Xcode 27.2+
        compatibleXcodeVersions: .upToNextMajor(.init(27, 2, 0)),
        plugins: [],
        generationOptions: .options(
            // Package.resolved is committed and owned by Xcode, so Tuist doesn't need its own package lock
            disablePackageVersionLocking: true,
            // The auto-generated "Generate Project" scheme embeds machine-specific absolute paths
            includeGenerateScheme: false,
            // Resolve packages with the system git (replaces the deprecated resolveDependenciesWithSystemScm)
            additionalPackageResolutionArguments: ["-scmProvider", "system"],
            projectFormat: .xcproj
        )
    )
)
