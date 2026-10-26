@preconcurrency import XCTest
import hCore

@testable import CrossSell

@MainActor
final class CrossSellTrackingTests: XCTestCase {
    weak var sut: MockEventTrackingClient?

    private let storeLink =
        "https://www.hedvig.com/api/redirect/recommend?attributed_to=HEDVIG&initiated_from=APP"
        + "&attribution.userFlow=HOME&attribution.experiments.ACCIDENT_DISCOUNT=NO_DISCOUNT"
        + "&next=%2Fse-en%2Finsurances%2Faccident&code=accident50app&requiresAuthorization=true"

    override func tearDown() async throws {
        Dependencies.shared.remove(for: EventTrackingClient.self)
        Dependencies.shared.remove(for: URLOpener.self)
        await delay(0.0000001)
        XCTAssertNil(sut)
    }

    func testTrackedEventCarriesOfferIdAndCampaignCodeInsteadOfTheLink() {
        let eventTracker = MockData.createMockEventTrackingClient()
        sut = eventTracker

        makeCrossSell(id: "crossSell:ACCIDENT", link: storeLink).track(.clicked, from: .home)

        XCTAssertEqual(
            eventTracker.trackedEvents,
            [
                .init(
                    name: "cross_sell_clicked",
                    parameters: [
                        "user_flow": "home",
                        "offer_id": "crossSell:ACCIDENT",
                        "campaign_code": "accident50app",
                    ]
                )
            ]
        )
    }

    func testEveryEventNameMatchesAndroid() {
        let eventTracker = MockData.createMockEventTrackingClient()
        sut = eventTracker
        let crossSell = makeCrossSell(link: storeLink)

        crossSell.track(.shown, from: .inChat)
        crossSell.track(.clicked, from: .inChat)
        crossSell.track(.dismissed, from: .inChat)

        XCTAssertEqual(
            eventTracker.trackedEvents.map(\.name),
            ["cross_sell_shown", "cross_sell_clicked", "cross_sell_dismissed"]
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

    func testLinkWithoutCampaignCodeSendsNoCampaignCode() {
        let crossSell = makeCrossSell(
            id: "crossSell:CAR",
            link: "https://www.hedvig.com/api/redirect/recommend?next=%2Fse%2Fbil&requiresAuthorization=true"
        )

        XCTAssertEqual(
            crossSell.analyticsParameters(from: .insurances),
            ["user_flow": "insurances", "offer_id": "crossSell:CAR"]
        )
    }

    func testCampaignCodeIsPercentDecodedAndKeepsAPlus() {
        let encoded = makeCrossSell(link: "https://www.hedvig.com/r?code=r%C3%A4tt%2B50%20off")
        XCTAssertEqual(encoded.campaignCode, "rätt+50 off")
        XCTAssertEqual(makeCrossSell(link: "https://www.hedvig.com/r?code=summer+10").campaignCode, "summer+10")
        XCTAssertNil(makeCrossSell(link: "https://www.hedvig.com/r?code=").campaignCode)
        XCTAssertNil(makeCrossSell(link: "https://www.hedvig.com/se/forsakringar/djurforsakring").campaignCode)
    }

    func testSecondTapWhileTheStoreIsOpeningOpensNothingAndCountsNoClick() async {
        let eventTracker = MockData.createMockEventTrackingClient()
        let urlOpener = MockData.createMockURLOpener()
        urlOpener.holdsOpens = true
        sut = eventTracker
        let storeOpener = CrossSellStoreOpener()
        let crossSell = makeCrossSell(link: storeLink)

        let firstTap = Task { await storeOpener.open(crossSell, from: .home) }
        while !urlOpener.isHoldingAnOpen { await Task.yield() }
        let secondTapOpened = await storeOpener.open(crossSell, from: .home)
        urlOpener.finishHeldOpen()
        let firstTapOpened = await firstTap.value

        XCTAssertTrue(firstTapOpened)
        XCTAssertFalse(secondTapOpened)
        XCTAssertEqual(urlOpener.openedURLs.map(\.absoluteString), [storeLink])
        XCTAssertEqual(eventTracker.trackedEvents.map(\.name), ["cross_sell_clicked"])
    }

    func testTapAfterTheStoreOpenedIsANewLaunch() async {
        let eventTracker = MockData.createMockEventTrackingClient()
        let urlOpener = MockData.createMockURLOpener()
        sut = eventTracker
        let storeOpener = CrossSellStoreOpener()
        let crossSell = makeCrossSell(link: storeLink)

        await storeOpener.open(crossSell, from: .home)
        await storeOpener.open(crossSell, from: .home)

        XCTAssertEqual(urlOpener.openedURLs.count, 2)
        XCTAssertEqual(eventTracker.trackedEvents.map(\.name), ["cross_sell_clicked", "cross_sell_clicked"])
    }

    func testShownTrackerReportsEachOfferOncePerVisit() {
        let eventTracker = MockData.createMockEventTrackingClient()
        sut = eventTracker
        let tracker = CrossSellShownTracker(source: .home)
        let car = makeCrossSell(id: "crossSell:CAR", link: storeLink)
        let pet = makeCrossSell(id: "crossSell:PET", link: storeLink)

        tracker.offerWasShown(car)
        tracker.offerWasShown(pet)
        tracker.offerWasShown(car)
        tracker.endVisit()
        tracker.offerWasShown(car)

        XCTAssertEqual(
            eventTracker.trackedEvents.map { $0.parameters["offer_id"] },
            ["crossSell:CAR", "crossSell:PET", "crossSell:CAR"]
        )
        XCTAssertEqual(Set(eventTracker.trackedEvents.map(\.name)), ["cross_sell_shown"])
    }

    func testShownTrackerIgnoresAddonRecommendations() {
        let eventTracker = MockData.createMockEventTrackingClient()
        sut = eventTracker
        let tracker = CrossSellShownTracker(source: .addon)

        tracker.offerWasShown(
            .addon(
                .init(
                    id: "addon-id",
                    title: "Travel Plus",
                    description: "description",
                    buttonText: "See price",
                    deepLink: "https://link.dev.hedvigit.com/travel-addon",
                    imageUrl: nil
                )
            )
        )

        XCTAssertTrue(eventTracker.trackedEvents.isEmpty)
    }

    private func makeCrossSell(id: String = "crossSell:ACCIDENT", link: String) -> CrossSell {
        .init(
            id: id,
            title: "Accident insurance",
            description: "description",
            buttonTitle: "See price",
            webActionURL: link,
            imageUrl: nil,
            buttonDescription: "button description"
        )
    }
}
