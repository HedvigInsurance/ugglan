import Foundation
import ProjectDescription

let dependencies = Dependencies(
    swiftPackageManager: [
        .remote(url: "https://github.com/Adyen/adyen-ios", requirement: .upToNextMajor(from: "3.8.4")),
        .remote(url: "https://github.com/wickwirew/Runtime", requirement: .exact("2.2.2")),
        .remote(
            url: "https://github.com/firebase/firebase-ios-sdk",
            requirement: .upToNextMajor(from: "7.3.1")
        ),
        .remote(url: "https://github.com/apollographql/apollo-ios", requirement: .exact("0.41.0")),
        .remote(url: "https://github.com/HedvigInsurance/Flow", requirement: .upToNextMajor(from: "1.8.8")),
        .remote(
            url: "https://github.com/HedvigInsurance/Form",
            requirement: .exact("3.0.8")
        ),
        .remote(
            url: "https://github.com/HedvigInsurance/Presentation",
            requirement: .upToNextMajor(from: "2.0.1")
        ),
        .remote(url: "https://github.com/yannickl/DynamicColor", requirement: .upToNextMajor(from: "5.0.1")),
        .remote(url: "https://github.com/HedvigInsurance/Disk", requirement: .upToNextMajor(from: "0.6.4")),
        .remote(url: "https://github.com/onevcat/Kingfisher", requirement: .upToNextMajor(from: "6.0.1")),
        .remote(url: "https://github.com/SnapKit/SnapKit", requirement: .upToNextMajor(from: "5.0.1")),
        .remote(
            url: "https://github.com/bmoliveira/MarkdownKit",
            requirement: .upToNextMajor(from: "1.7.1")
        ),
        .remote(
            url: "https://github.com/mixpanel/mixpanel-swift",
            requirement: .upToNextMajor(from: "2.8.1")
        ),
        .remote(url: "https://github.com/HeroTransitions/Hero", requirement: .exact("1.5.0")),
        .remote(
            url: "https://github.com/getsentry/sentry-cocoa",
            requirement: .upToNextMajor(from: "6.0.12")
        ),
        .remote(
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            requirement: .upToNextMajor(from: "1.8.2")
        ),
        .remote(url: "https://github.com/shakebugs/shake-ios", requirement: .exact("14.1.5")),
    ],
    platforms: [.iOS]
)
