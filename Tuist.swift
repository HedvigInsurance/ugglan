import ProjectDescription

let tuist = Tuist(
    project: .tuist(
        // The committed project.xcproj (JSON) format can only be opened by Xcode 27.2+
        compatibleXcodeVersions: .upToNextMajor(.init(27, 2, 0)),
        plugins: [],
        generationOptions: .options(
            // Resolve packages with the system git (replaces the deprecated resolveDependenciesWithSystemScm)
            // The auto-generated "Generate Project" scheme embeds machine-specific absolute paths
            includeGenerateScheme: false,
            // Package.resolved is committed and owned by Xcode; without this Tuist overwrites it with the
            // ignored, machine-local .package.resolved
            disablePackageVersionLocking: true,
            additionalPackageResolutionArguments: ["-scmProvider", "system"],
            projectFormat: .xcproj
        )
    )
)
