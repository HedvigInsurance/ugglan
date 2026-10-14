import ProjectDescription

extension DeploymentTargets {
    // XCTest in the Xcode 27 SDK is built for iOS 17, so a test bundle at 16.0 links a newer dylib and ld
    // warns on every test target. Xcode 27 cannot run tests on an iOS 16 simulator anyway.
    public static let tests: DeploymentTargets = .iOS("17.0")
}
