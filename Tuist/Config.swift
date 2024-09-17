import ProjectDescription

let config = Config(
    compatibleXcodeVersions: .list([
        .upToNextMajor(.init(15, 4, 0)),
        .upToNextMinor(.init(16, 0, 0)),
    ]),
    cloud: nil,
    cache: nil,
    swiftVersion: nil,
    plugins: [],
    generationOptions: .options(resolveDependenciesWithSystemScm: true)
)
