import Logger
import TestDependencies
@preconcurrency import XCTest

@testable import hCore

@MainActor
final class UnleashExperimentProviderTests: XCTestCase {
    weak var sut: UnleashExperimentProvider?
    private var featureFlagsClient: MockFeatureFlagsClient!
    private var logger: MockLogger!
    private var originalLog: (any Logging)!
    private let noDiscount = Experiment(name: "ACCIDENT_DISCOUNT", variant: "NO_DISCOUNT")

    override func setUp() async throws {
        featureFlagsClient = MockData.createMockFeatureFlagsClient()
        originalLog = log
        logger = MockLogger()
        log = logger
        try await FeatureFlags.shared.setup(with: memberContext("1"))
        // Every test starts with toggles that are not known to be the member's.
        await send(experiments: nil)
    }

    override func tearDown() async throws {
        log = originalLog
        Dependencies.shared.remove(for: FeatureFlagsClient.self)
        await delay(0.0000001)
        XCTAssertNil(sut)
    }

    /// Publishes feature data carrying `experiments` and waits for `FeatureFlags.shared` to hold it.
    private func send(experiments: [Experiment]?, isPuppyGuideEnabled: Bool = false) async {
        featureFlagsClient.send(.allOff(experiments: experiments, isPuppyGuideEnabled: isPuppyGuideEnabled))
        await waitUntil(description: "feature data with \(String(describing: experiments)) arrives") {
            FeatureFlags.shared.experiments == experiments
                && FeatureFlags.shared.isPuppyGuideEnabled == isPuppyGuideEnabled
        }
    }

    /// The Unleash context of a logged-in member, as `AppDelegate` builds it.
    private func memberContext(_ memberId: String) -> [String: String] {
        ["memberId": memberId, FeatureFlags.userId: memberId]
    }

    private func makeProvider(memberStateTimeout: TimeInterval) -> UnleashExperimentProvider {
        let provider = UnleashExperimentProvider(memberStateTimeout: memberStateTimeout)
        sut = provider
        return provider
    }

    func testActiveExperimentsWithTheMembersTogglesInHandAnswersAtOnce() async {
        await send(experiments: [noDiscount])
        let provider = makeProvider(memberStateTimeout: 3)

        let clock = ContinuousClock()
        let start = clock.now
        let experiments = await provider.activeExperiments()

        XCTAssertEqual(experiments, [noDiscount])
        XCTAssertLessThan(clock.now - start, .seconds(1))
    }

    func testActiveExperimentsWaitsForTheMembersToggles() async {
        let provider = makeProvider(memberStateTimeout: 3)
        let featureFlagsClient = featureFlagsClient!
        let noDiscount = noDiscount
        Task {
            try? await Task.sleep(for: .milliseconds(100))
            featureFlagsClient.send(.allOff(experiments: [noDiscount]))
        }

        let experiments = await provider.activeExperiments()

        XCTAssertEqual(experiments, [noDiscount])
    }

    func testActiveExperimentsAfterReLoginWaitsForTheNewMembersTogglesInsteadOfThePreviousOnes() async throws {
        // The toggles in hand were fetched for the member logged in before.
        await send(experiments: [])
        // Logging out registers a fresh client, which has nothing to publish yet when the login sets it up.
        let clientAfterLogout = MockData.createMockFeatureFlagsClient()
        try await FeatureFlags.shared.setup(with: memberContext("123"))
        let provider = makeProvider(memberStateTimeout: 3)
        let noDiscount = noDiscount
        Task {
            try? await Task.sleep(for: .milliseconds(100))
            clientAfterLogout.send(.allOff(experiments: [noDiscount]))
        }

        let experiments = await provider.activeExperiments()

        XCTAssertEqual(experiments, [noDiscount])
    }

    func testActiveExperimentsAfterATimeoutAnswersAtOnceUntilTheFlagsChange() async {
        let provider = makeProvider(memberStateTimeout: 0.2)
        let clock = ContinuousClock()

        var start = clock.now
        let firstAnswer = await provider.activeExperiments()
        XCTAssertEqual(firstAnswer, [])
        XCTAssertGreaterThanOrEqual(clock.now - start, .milliseconds(200))

        start = clock.now
        let secondAnswer = await provider.activeExperiments()
        XCTAssertEqual(secondAnswer, [])
        XCTAssertLessThan(clock.now - start, .milliseconds(100))

        // A change of the toggles may be the member's own arriving, so it is worth waiting again.
        await send(experiments: nil, isPuppyGuideEnabled: true)
        start = clock.now
        let thirdAnswer = await provider.activeExperiments()
        XCTAssertEqual(thirdAnswer, [])
        XCTAssertGreaterThanOrEqual(clock.now - start, .milliseconds(200))
    }

    func testActiveExperimentsAfterATimeoutDoesNotWaitAgainForTheSameFlagsSetUpAgain() async throws {
        let provider = makeProvider(memberStateTimeout: 0.2)
        _ = await provider.activeExperiments()

        // While Unleash is unreachable the app sets the flags up again every second, republishing the same toggles.
        try await FeatureFlags.shared.setup(with: memberContext("1"))
        featureFlagsClient.send(.allOff(experiments: nil))
        await delay(0.1)
        let clock = ContinuousClock()
        let start = clock.now
        let answer = await provider.activeExperiments()

        XCTAssertEqual(answer, [])
        XCTAssertLessThan(clock.now - start, .milliseconds(100))
    }

    func testActiveExperimentsAfterATimeoutWaitsAgainForANewMember() async {
        let provider = makeProvider(memberStateTimeout: 0.2)
        _ = await provider.activeExperiments()

        FeatureFlags.shared.updateContext(context: memberContext("123"))
        let clock = ContinuousClock()
        let start = clock.now
        let answer = await provider.activeExperiments()

        XCTAssertEqual(answer, [])
        XCTAssertGreaterThanOrEqual(clock.now - start, .milliseconds(200))
    }

    func testActiveExperimentsLogsAWarningEachTimeItGivesUpWaiting() async {
        let provider = makeProvider(memberStateTimeout: 0.2)

        _ = await provider.activeExperiments()
        _ = await provider.activeExperiments()
        XCTAssertEqual(logger.warnings.count, 1, "the second call answered at once without waiting")

        await send(experiments: nil, isPuppyGuideEnabled: true)
        _ = await provider.activeExperiments()
        XCTAssertEqual(logger.warnings.count, 2)
    }

    func testActiveExperimentsLogsNothingWhenTheMembersTogglesArriveInTime() async {
        let provider = makeProvider(memberStateTimeout: 3)
        let featureFlagsClient = featureFlagsClient!
        let noDiscount = noDiscount
        Task {
            try? await Task.sleep(for: .milliseconds(100))
            featureFlagsClient.send(.allOff(experiments: [noDiscount]))
        }

        _ = await provider.activeExperiments()

        XCTAssertTrue(logger.warnings.isEmpty)
    }
}
