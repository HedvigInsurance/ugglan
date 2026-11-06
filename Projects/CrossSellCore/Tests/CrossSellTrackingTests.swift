import Foundation
import TestDependencies
import Testing
import hCore

@testable import CrossSellCore

extension CrossSellDependencySuite {
    @MainActor
    final class CrossSellTrackingTests {
        private weak var sut: MockEventTrackingClient?
        private var eventTracker: MockEventTrackingClient!

        private static let storeLink = link(
            query: "attributed_to=HEDVIG&initiated_from=APP"
                + "&attribution.userFlow=HOME&attribution.experiments.ACCIDENT_DISCOUNT=NO_DISCOUNT"
                + "&next=%2Fse-en%2Finsurances%2Faccident&code=accident50app&requiresAuthorization=true"
        )

        init() {
            eventTracker = MockData.createMockEventTrackingClient()
            sut = eventTracker
        }

        // Stands in for the old tearDown: deinit is nonisolated and can't await, so each test calls this last.
        private func expectTrackerReleased() async {
            eventTracker = nil
            Dependencies.shared.remove(for: EventTrackingClient.self)
            Dependencies.shared.remove(for: URLOpener.self)
            await delay(0.0000001)
            #expect(sut == nil, "the mock tracker must not outlive its dependency registration")
        }

        @Test
        func eventNamesMatchAndroid() async {
            #expect(CrossSellEvent.shown.rawValue == "cross_sell_shown")
            #expect(CrossSellEvent.clicked.rawValue == "cross_sell_clicked")
            #expect(CrossSellEvent.dismissed.rawValue == "cross_sell_dismissed")

            await expectTrackerReleased()
        }

        @Test
        func trackedEventCarriesOfferIdCampaignCodeAndExperimentGroupInsteadOfTheLink() async {
            makeCrossSell(link: Self.storeLink).track(.clicked)

            #expect(
                eventTracker.trackedEvents == [
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

            await expectTrackerReleased()
        }

        @Test
        func userFlowIsTheBackendUserFlowEachSourceFetchesWith() async {
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
                #expect(source.analyticsUserFlow == userFlow, "\(source)")
            }

            await expectTrackerReleased()
        }

        @Test
        func linkWithoutCodeOrExperimentsSendsOnlyUserFlowAndOfferId() async {
            let crossSell = makeCrossSell(
                id: "crossSell:CAR",
                source: .insurances,
                link: Self.link(query: "next=%2Fse%2Fbil&requiresAuthorization=true")
            )

            #expect(crossSell.analyticsParameters == ["user_flow": "insurances", "offer_id": "crossSell:CAR"])

            await expectTrackerReleased()
        }

        @Test
        func campaignCodeIsPercentDecodedAndKeepsAPlus() async {
            let encoded = makeCrossSell(link: Self.link(query: "code=r%C3%A4tt%2B50%20off"))
            #expect(encoded.campaignCode == "rätt+50 off")
            #expect(makeCrossSell(link: Self.link(query: "code=summer+10")).campaignCode == "summer+10")
            #expect(makeCrossSell(link: Self.link(query: "code=")).campaignCode == nil)

            await expectTrackerReleased()
        }

        @Test
        func everyExperimentInTheLinkBecomesAParameterNamedAfterIt() async {
            let crossSell = makeCrossSell(
                link: Self.link(
                    query: "attribution.experiments.ACCIDENT_DISCOUNT=NO_DISCOUNT"
                        + "&attribution.experiments.RECOMMENDED_CROSS_SELL=B"
                )
            )

            #expect(crossSell.experiments == ["ACCIDENT_DISCOUNT": "NO_DISCOUNT", "RECOMMENDED_CROSS_SELL": "B"])

            await expectTrackerReleased()
        }

        @Test
        func experimentFirebaseCannotTakeAsAParameterNameIsLeftOut() async {
            let crossSell = makeCrossSell(
                link: Self.link(
                    query: "attribution.experiments.1ST=A&attribution.experiments.WITH-DASH=B"
                        + "&attribution.experiments.\(String(repeating: "X", count: 41))=C"
                )
            )

            #expect(crossSell.experiments == [:])

            await expectTrackerReleased()
        }

        @Test
        func experimentNeverReplacesOneOfTheEventsOwnParameters() async {
            let crossSell = makeCrossSell(link: Self.link(query: "attribution.experiments.offer_id=X"))

            #expect(crossSell.analyticsParameters["offer_id"] == "crossSell:ACCIDENT")

            await expectTrackerReleased()
        }

        @Test
        func openingTheStoreCountsOneClick() async {
            let urlOpener = MockData.createMockURLOpener()

            let opened = await makeCrossSell(link: Self.storeLink).openStore()

            #expect(opened)
            #expect(urlOpener.openedURLs.map(\.absoluteString) == [Self.storeLink])
            #expect(eventTracker.trackedEvents.map(\.name) == ["cross_sell_clicked"])

            await expectTrackerReleased()
        }

        @Test
        func aStoreLinkTheSystemDoesNotOpenCountsNoClick() async {
            let urlOpener = MockData.createMockURLOpener()
            urlOpener.systemOpensURLs = false

            let opened = await makeCrossSell(link: Self.storeLink).openStore()

            #expect(!opened)
            #expect(eventTracker.trackedEvents.isEmpty)

            await expectTrackerReleased()
        }

        @Test
        func shownTrackerReportsEachOfferOncePerVisit() async {
            let tracker = CrossSellShownTracker()
            let car = makeCrossSell(id: "crossSell:CAR", link: Self.storeLink)
            let pet = makeCrossSell(id: "crossSell:PET", link: Self.storeLink)

            tracker.offerWasShown(car)
            tracker.offerWasShown(pet)
            tracker.offerWasShown(car)
            tracker.endVisit()
            tracker.offerWasShown(car)

            #expect(eventTracker.trackedEvents.map(\.name) == Array(repeating: "cross_sell_shown", count: 3))
            #expect(
                eventTracker.trackedEvents.map { $0.parameters["offer_id"] }
                    == ["crossSell:CAR", "crossSell:PET", "crossSell:CAR"]
            )

            await expectTrackerReleased()
        }

        @Test
        func shownTrackerIgnoresAddonRecommendations() async {
            let addon = AddonCrossSell(
                id: "addon-id",
                title: "Travel Plus",
                description: "description",
                buttonText: "See price",
                deepLink: Self.storeLink,
                imageUrl: nil
            )

            CrossSellShownTracker().offerWasShown(.addon(addon))

            #expect(eventTracker.trackedEvents.isEmpty)

            await expectTrackerReleased()
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
}
