import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.dependenciesFramework(
    name: "CoreDependencies",
    externalDependencies: ExternalDependencies.allCases.filter(\.isCoreDependency),
    scripts: [
        .pre(
            path: "../../scripts/build-local-umbrella.sh",
            name: "Build HedvigShared (local umbrella mode)",
            // In local mode, declare the framework binary as an output so Xcode
            // invalidates the Swift compile + link of CoreDependencies whenever
            // gradle relinks HedvigShared. Without this, Xcode caches the old
            // statically-linked CoreDependencies.framework and the .app ships
            // stale Kotlin code.
            // In released mode the SPM HedvigShared target owns this path —
            // leave outputPaths empty to avoid double-declaring ownership.
            outputPaths: isLocalUmbrellaMode
                ? ["$(BUILT_PRODUCTS_DIR)/HedvigShared.framework/HedvigShared"]
                : [],
            basedOnDependencyAnalysis: false
        )
    ]
)
