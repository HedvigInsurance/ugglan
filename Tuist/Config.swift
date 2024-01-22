import ProjectDescription

let config = Config(
    compatibleXcodeVersions: .list([
        .upToNextMajor(Version(15, 0, 0))
    ]),
    cloud: nil,
    cache: nil,
    swiftVersion: nil,
    plugins: [],
    generationOptions: .options(resolveDependenciesWithSystemScm: true)
)
