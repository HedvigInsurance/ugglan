import Combine
import Environment
import TestDependencies
import XCTest

@testable import hCore

@MainActor
final class FeatureFlagsUnleashTests: XCTestCase {
    private var session: FakePollerSession!
    private var sut: FeatureFlagsUnleash!
    private var published: [FeatureData] = []
    private var cancellable: AnyCancellable?

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

    override func setUp() async throws {
        session = FakePollerSession()
        sut = FeatureFlagsUnleash(environment: .staging, pollerSession: session)
        published = []
        cancellable = sut.featureData.sink { [weak self] in self?.published.append($0) }
    }

    override func tearDown() async throws {
        cancellable = nil
        sut = nil
    }

    func testTheFetchCarriesTheMemberAsUserIdAndAsTheMemberIdProperty() async throws {
        session.enqueue(.toggles(memberToggles))

        try await sut.setup(with: member)

        let query = try XCTUnwrap(session.requestedURLs.last?.query)
        XCTAssertTrue(query.contains("userId=123"), query)
        XCTAssertTrue(query.contains("properties%5BmemberId%5D=123"), query)
    }

    func testExperimentsComeFromTheTogglesFetchedForTheMember() async throws {
        session.enqueue(.toggles(memberToggles))

        try await sut.setup(with: member)

        XCTAssertEqual(published.last?.experiments, [noDiscount])
    }

    func testADisabledFlagPutsTheMemberInNoExperiment() async throws {
        session.enqueue(.toggles(anonymousToggles))

        try await sut.setup(with: nobody)

        XCTAssertEqual(published.last?.experiments, [])
    }

    func testExperimentsAreUnknownUntilTheNewMembersFetchLands() async throws {
        session.enqueue(.toggles(anonymousToggles))
        try await sut.setup(with: nobody)
        session.enqueue(.toggles(memberToggles))

        sut.updateContext(context: member)

        let beforeTheFetch = try XCTUnwrap(published.last)
        XCTAssertNil(beforeTheFetch.experiments)
        await waitUntil(description: "the member's toggles arrive", timeout: sdkFetchTimeout) { [self] in
            published.last?.experiments == [noDiscount]
        }
    }

    func testASetupForANewMemberMakesExperimentsUnknownUntilItsFetchLands() async throws {
        session.enqueue(.toggles(anonymousToggles))
        try await sut.setup(with: nobody)
        session.enqueue(.toggles(memberToggles))

        // Login runs setup again with the member in the context, while Home already queries cross-sells.
        try await sut.setup(with: member)

        XCTAssertEqual(published.map(\.experiments).suffix(3), [[], nil, [noDiscount]])
    }

    func testANotModifiedAnswerAfterTheContextChangeCountsAsTheNewMembersState() async throws {
        session.enqueue(.toggles(memberToggles))
        try await sut.setup(with: member)
        // The SDK keeps one ETag across contexts, so a member with the same toggles gets a 304 and no event.
        session.enqueue(.notModified)

        sut.updateContext(context: otherMember)

        await waitUntil(
            description: "the 304 is taken as the other member's state",
            timeout: sdkFetchTimeout
        ) { [self] in
            published.last?.experiments == [noDiscount]
        }
        XCTAssertEqual(session.requestedURLs.count, 2)
    }

    func testExperimentsStayUnknownWhenTheMembersFetchFails() async throws {
        session.enqueue(.toggles(anonymousToggles))
        try await sut.setup(with: nobody)
        // Nothing enqueued: the member's fetch fails.

        sut.updateContext(context: member)

        await waitUntil(description: "the member's fetch was attempted", timeout: sdkFetchTimeout) { [self] in
            session.requestedURLs.count == 2
        }
        await delay(0.1)
        let latest = try XCTUnwrap(published.last)
        XCTAssertNil(latest.experiments)
    }

    func testRemovingTheMemberFromTheContextFetchesForNobody() async throws {
        session.enqueue(.toggles(memberToggles))
        try await sut.setup(with: member)
        session.enqueue(.toggles(anonymousToggles))

        sut.updateContext(context: nobody)

        await waitUntil(description: "nobody's toggles arrive", timeout: sdkFetchTimeout) { [self] in
            published.last?.experiments == []
        }
        let query = try XCTUnwrap(session.requestedURLs.last?.query)
        XCTAssertFalse(query.contains("userId"), query)
        XCTAssertFalse(query.contains("memberId"), query)
    }

    func testAnUnchangedContextIsNotFetchedAgain() async throws {
        session.enqueue(.toggles(memberToggles))
        try await sut.setup(with: member)

        sut.updateContext(context: member)

        await delay(0.1)
        XCTAssertEqual(session.requestedURLs.count, 1)
        XCTAssertEqual(published.last?.experiments, [noDiscount])
    }
}
