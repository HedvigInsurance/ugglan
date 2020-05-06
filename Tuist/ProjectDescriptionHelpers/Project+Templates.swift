import ProjectDescription

public enum uFeatureTarget {
    case framework
    case tests
    case testing
}


extension Project {
    public static func framework(name: String,
                                 targets: Set<uFeatureTarget> = Set([.framework, .tests, .testing]),
                                 dependencies: [String] = [],
                                 sdks: [String] = []) -> Project {
        
        // Configurations
        let frameworkConfigurations: [CustomConfiguration] = [
            .debug(name: "Debug", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/iOS/iOS-Framework.xcconfig")),
            .debug(name: "Release", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/iOS/iOS-Framework.xcconfig"))
        ]
        let testsConfigurations: [CustomConfiguration] = [
            .debug(name: "Debug", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig")),
            .debug(name: "Release", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig"))
        ]
        let appConfigurations: [CustomConfiguration] = [
            .debug(name: "Debug", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig")),
            .debug(name: "Release", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/iOS/iOS-Base.xcconfig"))
        ]
        let projectConfigurations: [CustomConfiguration] = [
            .debug(name: "Debug", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/Base/Configurations/Debug.xcconfig")),
            .debug(name: "Release", settings: [String: SettingValue](), xcconfig: .relativeToRoot("Configurations/Base/Configurations/Release.xcconfig"))
        ]
        
        // Test dependencies
        var testsDependencies: [TargetDependency] = [
            .target(name: "\(name)"),
            .project(target: "UnitTests", path: .relativeToRoot("Projects/UnitTests"))
        ]
        dependencies.forEach { testsDependencies.append(.project(target: "\($0)Testing", path: .relativeToRoot("Projects/\($0)"))) }
        
        // Target dependencies
        var targetDependencies: [TargetDependency] = dependencies.map({ .project(target: $0, path: .relativeToRoot("Projects/\($0)")) })
        targetDependencies.append(contentsOf: sdks.map({.sdk(name: $0)}))
        
        // Project targets
        var projectTargets: [Target] = []
        if targets.contains(.framework) {
            projectTargets.append(Target(name: name,
                                         platform: .iOS,
                                         product: .framework,
                                         bundleId: "io.tuist.\(name)",
                infoPlist: .default,
                sources: ["Sources/**/*.swift"],
                dependencies: targetDependencies,
                settings: Settings(configurations: frameworkConfigurations)))
        }
        if targets.contains(.testing) {
            projectTargets.append(Target(name: "\(name)Testing",
                platform: .iOS,
                product: .framework,
                bundleId: "com.hedvig.\(name)Testing",
                infoPlist: .default,
                sources: "Testing/**/*.swift",
                dependencies: [.target(name: "\(name)")],
                settings: Settings(configurations: frameworkConfigurations)))
        }
        if targets.contains(.tests) {
            projectTargets.append(Target(name: "\(name)Tests",
                platform: .iOS,
                product: .unitTests,
                bundleId: "com.hedvig.\(name)Tests",
                infoPlist: .default,
                sources: "Tests/**/*.swift",
                dependencies: testsDependencies,
                settings: Settings(configurations: testsConfigurations)))
        }
        
        // Project
        return Project(name: name,
                       organizationName: "Hedvig",
                       settings: Settings(configurations: projectConfigurations),
                       targets: projectTargets)
    }

}
