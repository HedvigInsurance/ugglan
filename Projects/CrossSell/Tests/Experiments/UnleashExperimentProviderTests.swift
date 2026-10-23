import TestDependencies
import XCTest

@testable import hCore

@MainActor
final class UnleashExperimentProviderTests: XCTestCase {
    private var flags: FakeFeatureFlagsClient!
    private var tracking: FakeEventTrackingClient!
    private let noDiscount = Experiment(name: "ACCIDENT_DISCOUNT", variant: "NO_DISCOUNT")

    override func setUp() async throws {
        let flags = FakeFeatureFlagsClient()
        let tracking = FakeEventTrackingClient()
        self.flags = flags
        self.tracking = tracking
        Dependencies.shared.add(module: Module { () -> FeatureFlagsClient in flags })
        Dependencies.shared.add(module: Module { () -> EventTrackingClient in tracking })
        try await FeatureFlags.shared.setup(with: [:])
        // Every test starts with toggles that are not known to be the member's.
        await send(experiments: nil)
    }

    override func tearDown() {
        Dependencies.shared.remove(for: FeatureFlagsClient.self)
        Dependencies.shared.remove(for: EventTrackingClient.self)
    }

    /// Publishes feature data carrying `experiments` and waits for `FeatureFlags.shared` to hold it.
    private func send(experiments: [Experiment]?, isPuppyGuideEnabled: Bool = false) async {
        flags.send(.allOff(experiments: experiments, isPuppyGuideEnabled: isPuppyGuideEnabled))
        await waitUntil(description: "feature data with \(String(describing: experiments)) arrives") {
            FeatureFlags.shared.experiments == experiments
                && FeatureFlags.shared.isPuppyGuideEnabled == isPuppyGuideEnabled
        }
    }

    func testAnswersFromTheMembersTogglesWithoutWaiting() async {
        await send(experiments: [noDiscount])
        let provider = UnleashExperimentProvider(memberStateTimeout: 3)

        let clock = ContinuousClock()
        let start = clock.now
        let experiments = await provider.activeExperiments()

        XCTAssertEqual(experiments, [noDiscount])
        XCTAssertLessThan(clock.now - start, .seconds(1))
    }

    func testWaitsForTheMembersTogglesWhenTheyAreNotInHandYet() async {
        let provider = UnleashExperimentProvider(memberStateTimeout: 3)
        let flags = flags!
        let noDiscount = noDiscount
        Task {
            try? await Task.sleep(for: .milliseconds(100))
            flags.send(.allOff(experiments: [noDiscount]))
        }

        let experiments = await provider.activeExperiments()

        XCTAssertEqual(experiments, [noDiscount])
    }

    func testGivesUpAfterTheTimeoutAndAnswersAtOnceUntilTheFlagsChange() async {
        let provider = UnleashExperimentProvider(memberStateTimeout: 0.2)
        let clock = ContinuousClock()

        var start = clock.now
        let firstAnswer = await provider.activeExperiments()
        XCTAssertEqual(firstAnswer, [])
        XCTAssertGreaterThanOrEqual(clock.now - start, .milliseconds(200))

        start = clock.now
        let secondAnswer = await provider.activeExperiments()
        XCTAssertEqual(secondAnswer, [])
        XCTAssertLessThan(clock.now - start, .milliseconds(100))

        // Any flag update may be the member's toggles arriving, so it is worth waiting again.
        await send(experiments: nil, isPuppyGuideEnabled: true)
        start = clock.now
        let thirdAnswer = await provider.activeExperiments()
        XCTAssertEqual(thirdAnswer, [])
        XCTAssertGreaterThanOrEqual(clock.now - start, .milliseconds(200))
    }

    func testUserPropertiesFollowTheMembersExperiments() async {
        let provider = UnleashExperimentProvider(memberStateTimeout: 3)
        let tracking = tracking!

        await send(experiments: [noDiscount])
        await waitUntil(description: "the experiment reaches the user properties") {
            tracking.userProperties["experiment_name"] == "ACCIDENT_DISCOUNT"
                && tracking.userProperties["experiment_variant"] == "NO_DISCOUNT"
        }

        await send(experiments: [])
        await waitUntil(description: "the user properties are cleared") {
            tracking.userProperties["experiment_name"] == .some(nil)
                && tracking.userProperties["experiment_variant"] == .some(nil)
        }
        withExtendedLifetime(provider) {}
    }

    func testUserPropertiesAreLeftAloneWhileTheTogglesAreNotTheMembers() async {
        let provider = UnleashExperimentProvider(memberStateTimeout: 3)

        await send(experiments: nil, isPuppyGuideEnabled: true)
        await delay(0.1)

        XCTAssertTrue(tracking.userPropertyChanges.isEmpty)
        withExtendedLifetime(provider) {}
    }
}
