import ProjectDescription

let config = Config(
    compatibleXcodeVersions: .list([
        .upToNextMajor(.init(16, 0, 0))
    ]),
    cloud: nil,
    swiftVersion: nil,
    plugins: [],
    generationOptions: .options(resolveDependenciesWithSystemScm: true)
)
