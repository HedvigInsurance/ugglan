@preconcurrency import XCTest
import hCore

@testable import CrossSell

@MainActor
final class CrossSellTrackingTests: XCTestCase {
    weak var sut: MockEventTrackingClient?
    private var eventTracker: MockEventTrackingClient!

    private static let storeLink = link(
        query: "attributed_to=HEDVIG&initiated_from=APP"
            + "&attribution.userFlow=HOME&attribution.experiments.ACCIDENT_DISCOUNT=NO_DISCOUNT"
            + "&next=%2Fse-en%2Finsurances%2Faccident&code=accident50app&requiresAuthorization=true"
    )

    override func setUp() async throws {
        try await super.setUp()
        eventTracker = MockData.createMockEventTrackingClient()
        sut = eventTracker
    }

    override func tearDown() async throws {
        eventTracker = nil
        Dependencies.shared.remove(for: EventTrackingClient.self)
        Dependencies.shared.remove(for: URLOpener.self)
        await delay(0.0000001)
        XCTAssertNil(sut)
    }

    func testEventNamesMatchAndroid() {
        XCTAssertEqual(CrossSellEvent.shown.rawValue, "cross_sell_shown")
        XCTAssertEqual(CrossSellEvent.clicked.rawValue, "cross_sell_clicked")
        XCTAssertEqual(CrossSellEvent.dismissed.rawValue, "cross_sell_dismissed")
    }

    func testTrackedEventCarriesOfferIdCampaignCodeAndExperimentGroupInsteadOfTheLink() {
        makeCrossSell(link: Self.storeLink).track(.clicked)

        XCTAssertEqual(
            eventTracker.trackedEvents,
            [
                .init(
                    name: "cross_sell_clicked",
                    parameters: [
                        "user_flow": "home",
                        "offer_id": "crossSell:ACCIDENT",
                        "campaign_code": "accident50app",
                        "ACCIDENT_DISCOUNT": "NO_DISCOUNT",
                    ]
                )
            ]
        )
    }

    func testUserFlowIsTheBackendUserFlowEachSourceFetchesWith() {
        let userFlows: [(CrossSellSource, String)] = [
            (.home, "home"),
            (.homeXSell, "home_x_sell"),
            (.insurances, "insurances"),
            (.onboarding, "onboarding"),
            (.inChat, "in_chat_x_sell"),
            (.movingFlow(contractId: "c"), "smart_x_sell"),
            (.changeTier(contractId: "c"), "smart_x_sell"),
            (.addon, "smart_x_sell"),
            (.closedClaim(claimId: "claim", contractId: nil), "smart_x_sell"),
        ]
        for (source, userFlow) in userFlows {
            XCTAssertEqual(source.analyticsUserFlow, userFlow, "\(source)")
        }
    }

    func testLinkWithoutCodeOrExperimentsSendsOnlyUserFlowAndOfferId() {
        let crossSell = makeCrossSell(
            id: "crossSell:CAR",
            source: .insurances,
            link: Self.link(query: "next=%2Fse%2Fbil&requiresAuthorization=true")
        )

        XCTAssertEqual(crossSell.analyticsParameters, ["user_flow": "insurances", "offer_id": "crossSell:CAR"])
    }

    func testCampaignCodeIsPercentDecodedAndKeepsAPlus() {
        let encoded = makeCrossSell(link: Self.link(query: "code=r%C3%A4tt%2B50%20off"))
        XCTAssertEqual(encoded.campaignCode, "rätt+50 off")
        XCTAssertEqual(makeCrossSell(link: Self.link(query: "code=summer+10")).campaignCode, "summer+10")
        XCTAssertNil(makeCrossSell(link: Self.link(query: "code=")).campaignCode)
    }

    func testEveryExperimentInTheLinkBecomesAParameterNamedAfterIt() {
        let crossSell = makeCrossSell(
            link: Self.link(
                query: "attribution.experiments.ACCIDENT_DISCOUNT=NO_DISCOUNT"
                    + "&attribution.experiments.RECOMMENDED_CROSS_SELL=B"
            )
        )

        XCTAssertEqual(crossSell.experiments, ["ACCIDENT_DISCOUNT": "NO_DISCOUNT", "RECOMMENDED_CROSS_SELL": "B"])
    }

    func testExperimentFirebaseCannotTakeAsAParameterNameIsLeftOut() {
        let crossSell = makeCrossSell(
            link: Self.link(
                query: "attribution.experiments.1ST=A&attribution.experiments.WITH-DASH=B"
                    + "&attribution.experiments.\(String(repeating: "X", count: 41))=C"
            )
        )

        XCTAssertEqual(crossSell.experiments, [:])
    }

    func testExperimentNeverReplacesOneOfTheEventsOwnParameters() {
        let crossSell = makeCrossSell(link: Self.link(query: "attribution.experiments.offer_id=X"))

        XCTAssertEqual(crossSell.analyticsParameters["offer_id"], "crossSell:ACCIDENT")
    }

    func testOpeningTheStoreCountsOneClick() async {
        let urlOpener = MockData.createMockURLOpener()

        let opened = await makeCrossSell(link: Self.storeLink).openStore()

        XCTAssertTrue(opened)
        XCTAssertEqual(urlOpener.openedURLs.map(\.absoluteString), [Self.storeLink])
        XCTAssertEqual(eventTracker.trackedEvents.map(\.name), ["cross_sell_clicked"])
    }

    func testAStoreLinkTheSystemDoesNotOpenCountsNoClick() async {
        let urlOpener = MockData.createMockURLOpener()
        urlOpener.systemOpensURLs = false

        let opened = await makeCrossSell(link: Self.storeLink).openStore()

        XCTAssertFalse(opened)
        XCTAssertTrue(eventTracker.trackedEvents.isEmpty)
    }

    func testShownTrackerReportsEachOfferOncePerVisit() {
        let tracker = CrossSellShownTracker()
        let car = makeCrossSell(id: "crossSell:CAR", link: Self.storeLink)
        let pet = makeCrossSell(id: "crossSell:PET", link: Self.storeLink)

        tracker.offerWasShown(car)
        tracker.offerWasShown(pet)
        tracker.offerWasShown(car)
        tracker.endVisit()
        tracker.offerWasShown(car)

        XCTAssertEqual(eventTracker.trackedEvents.map(\.name), Array(repeating: "cross_sell_shown", count: 3))
        XCTAssertEqual(
            eventTracker.trackedEvents.map { $0.parameters["offer_id"] },
            ["crossSell:CAR", "crossSell:PET", "crossSell:CAR"]
        )
    }

    func testShownTrackerIgnoresAddonRecommendations() {
        let addon = AddonCrossSell(
            id: "addon-id",
            title: "Travel Plus",
            description: "description",
            buttonText: "See price",
            deepLink: Self.storeLink,
            imageUrl: nil
        )

        CrossSellShownTracker().offerWasShown(.addon(addon))

        XCTAssertTrue(eventTracker.trackedEvents.isEmpty)
    }

    /// Builds a store link from its percent-encoded query; only the query is read by the tracking code.
    private nonisolated static func link(query: String) -> String {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.hedvig.com"
        components.percentEncodedQuery = query
        return components.string ?? ""
    }

    private func makeCrossSell(
        id: String = "crossSell:ACCIDENT",
        source: CrossSellSource = .home,
        link: String
    ) -> CrossSell {
        .init(
            id: id,
            source: source,
            title: "Accident insurance",
            description: "description",
            buttonTitle: "See price",
            webActionURL: link,
            imageUrl: nil,
            buttonDescription: "button description"
        )
    }
}
