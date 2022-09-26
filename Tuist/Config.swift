import ProjectDescription

let config = Config(
    compatibleXcodeVersions: .list([
        .exact("13.3"),
        .exact("13.3.1"),
        .exact("13.4"),
        .exact("13.4.1"),
        .exact("14.0"),
        .exact("14.0.1"),
    ]),
    cloud: nil,
    cache: nil,
    swiftVersion: nil,
    plugins: [],
    generationOptions: .options()
)
