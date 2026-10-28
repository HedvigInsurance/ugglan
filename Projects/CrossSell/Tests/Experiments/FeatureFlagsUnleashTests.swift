import Combine
import Environment
import Logger
import TestDependencies
@preconcurrency import XCTest

@testable import hCore

@MainActor
final class FeatureFlagsUnleashTests: XCTestCase {
    weak var sut: FeatureFlagsUnleash?
    private var session: MockPollerSession!
    private var client: FeatureFlagsUnleash!
    private var published: [FeatureData] = []
    private var cancellable: AnyCancellable?
    private var logger: MockLogger!
    private var originalLog: (any Logging)!

    private let member = ["memberId": "123", "userId": "123", "market": "SE"]
    private let otherMember = ["memberId": "456", "userId": "456", "market": "SE"]
    private let nobody = ["market": "SE"]
    private let noDiscount = Experiment(name: "ACCIDENT_DISCOUNT", variant: "NO_DISCOUNT")
    /// The SDK re-fetches on a background-QoS queue, which the system holds back for seconds under load.
    private let sdkFetchTimeout: TimeInterval = 10

    /// What Unleash answers for a member bucketed into NO_DISCOUNT.
    private let memberToggles = """
        {"toggles":[{"name":"accident_discount_experiment","enabled":true,\
        "variant":{"name":"NO_DISCOUNT","enabled":true}}]}
        """
    /// What Unleash answers with no member in the context: the gradual rollout resolves to off.
    private let anonymousToggles = """
        {"toggles":[{"name":"accident_discount_experiment","enabled":false,\
        "variant":{"name":"disabled","enabled":false}}]}
        """

    /// What Unleash answers for a member the accident discount flag is on for, with the given variant.
    private func toggles(variant: String, variantEnabled: Bool = true) -> String {
        """
        {"toggles":[{"name":"accident_discount_experiment","enabled":true,\
        "variant":{"name":"\(variant)","enabled":\(variantEnabled)}}]}
        """
    }

    override func setUp() async throws {
        originalLog = log
        logger = MockLogger()
        log = logger
        session = MockPollerSession()
        client = FeatureFlagsUnleash(environment: .staging, pollerSession: session)
        sut = client
        published = []
        cancellable = client.featureData.sink { [weak self] in self?.published.append($0) }
    }

    override func tearDown() async throws {
        cancellable = nil
        client = nil
        log = originalLog
        await delay(0.0000001)
        XCTAssertNil(sut)
    }

    func testSetupFetchesWithTheMemberAsUserIdAndMemberIdProperty() async throws {
        session.enqueue(.toggles(memberToggles))

        try await client.setup(with: member)

        let query = try XCTUnwrap(session.requestedURLs.last?.query)
        XCTAssertTrue(query.contains("userId=123"), query)
        XCTAssertTrue(query.contains("properties%5BmemberId%5D=123"), query)
    }

    func testSetupPublishesTheExperimentsFromTheMembersToggles() async throws {
        session.enqueue(.toggles(memberToggles))

        try await client.setup(with: member)

        XCTAssertEqual(published.last?.experiments, [noDiscount])
    }

    func testSetupWithADisabledFlagPublishesNoExperiment() async throws {
        session.enqueue(.toggles(anonymousToggles))

        try await client.setup(with: nobody)

        XCTAssertEqual(published.last?.experiments, [])
    }

    func testUpdateContextLeavesExperimentsUnknownUntilTheNewMembersFetchLands() async throws {
        session.enqueue(.toggles(anonymousToggles))
        try await client.setup(with: nobody)
        session.enqueue(.toggles(memberToggles))

        client.updateContext(context: member)

        let beforeTheFetch = try XCTUnwrap(published.last)
        XCTAssertNil(beforeTheFetch.experiments)
        await waitUntil(description: "the member's toggles arrive", timeout: sdkFetchTimeout) { [self] in
            published.last?.experiments == [noDiscount]
        }
    }

    func testSetupForANewMemberLeavesExperimentsUnknownUntilItsFetchLands() async throws {
        session.enqueue(.toggles(anonymousToggles))
        try await client.setup(with: nobody)
        session.enqueue(.toggles(memberToggles))

        // Login runs setup again with the member in the context, while Home already queries cross-sells.
        try await client.setup(with: member)

        XCTAssertEqual(published.map(\.experiments).suffix(3), [[], nil, [noDiscount]])
    }

    func testUpdateContextTakesANotModifiedAnswerAsTheNewMembersState() async throws {
        session.enqueue(.toggles(memberToggles))
        try await client.setup(with: member)
        // The SDK keeps one ETag across contexts, so a member with the same toggles gets a 304 and no event.
        session.enqueue(.notModified)

        client.updateContext(context: otherMember)

        await waitUntil(
            description: "the 304 is taken as the other member's state",
            timeout: sdkFetchTimeout
        ) { [self] in
            published.last?.experiments == [noDiscount]
        }
        XCTAssertEqual(session.requestedURLs.count, 2)
    }

    func testUpdateContextKeepsExperimentsUnknownWhenTheMembersFetchFails() async throws {
        session.enqueue(.toggles(anonymousToggles))
        try await client.setup(with: nobody)
        // Nothing enqueued: the member's fetch fails.

        client.updateContext(context: member)

        await waitUntil(description: "the member's fetch was attempted", timeout: sdkFetchTimeout) { [self] in
            session.requestedURLs.count == 2
        }
        await delay(0.1)
        let latest = try XCTUnwrap(published.last)
        XCTAssertNil(latest.experiments)
    }

    func testUpdateContextWithoutAMemberFetchesForNobody() async throws {
        session.enqueue(.toggles(memberToggles))
        try await client.setup(with: member)
        session.enqueue(.toggles(anonymousToggles))

        client.updateContext(context: nobody)

        await waitUntil(description: "nobody's toggles arrive", timeout: sdkFetchTimeout) { [self] in
            published.last?.experiments == []
        }
        let query = try XCTUnwrap(session.requestedURLs.last?.query)
        XCTAssertFalse(query.contains("userId"), query)
        XCTAssertFalse(query.contains("memberId"), query)
    }

    func testUpdateContextWithTheSameContextDoesNotFetchAgain() async throws {
        session.enqueue(.toggles(memberToggles))
        try await client.setup(with: member)

        client.updateContext(context: member)

        await delay(0.1)
        XCTAssertEqual(session.requestedURLs.count, 1)
        XCTAssertEqual(published.last?.experiments, [noDiscount])
    }

    func testSetupWithADisabledVariantPublishesNoExperiment() async throws {
        session.enqueue(.toggles(toggles(variant: "NO_DISCOUNT", variantEnabled: false)))

        try await client.setup(with: member)

        XCTAssertEqual(published.last?.experiments, [])
    }

    func testSetupDropsAndWarnsAboutAVariantThatIsNotScreamingSnakeCase() async throws {
        for variant in ["no-discount", "NoDiscount", "NO DISCOUNT", ""] {
            logger.warnings = []
            session.enqueue(.toggles(toggles(variant: variant)))

            try await client.setup(with: member)

            XCTAssertEqual(published.last?.experiments, [], "variant '\(variant)'")
            XCTAssertEqual(
                logger.warnings,
                ["Ignoring ACCIDENT_DISCOUNT variant '\(variant)': not SCREAMING_SNAKE_CASE"],
                "variant '\(variant)'"
            )
        }
    }
}
