import Apollo
import Flow
import Form
import Foundation
import Offer
import OfferTesting
import Presentation
import SwiftUI
import TestingUtil
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct OfferDebugRow {
    var title: String
    var action: () -> Void
}

struct Debug: View {
    @PresentableStore var store: DebugStore
    @State var presentFullScreen = false
    @State var prefersLargeTitles = false

    func openOffer<Mock: GraphQLMock>(locale: Localization.Locale, @GraphQLMockBuilder _ mocks: () -> Mock) {
        Localization.Locale.currentLocale = locale

        ApolloClient.createMock {
            mocks()
            sharedMocks
        }

        store.send(.openOffer(fullscreen: presentFullScreen, prefersLargeTitles: prefersLargeTitles))
    }

    func openDataCollection<Mock: GraphQLMock>(locale: Localization.Locale, @GraphQLMockBuilder _ mocks: () -> Mock) {
        Localization.Locale.currentLocale = locale

        ApolloClient.createMock {
            mocks()
        }

        store.send(.openDataCollection)
    }

    var body: some View {
        let rows = [
            OfferDebugRow(
                title: "Swedish apartment",
                action: {
                    openOffer(locale: .en_SE) {
                        QueryMock(GraphQL.QuoteBundleQuery.self) { _ in
                            .makeSwedishApartment()
                        }
                    }
                }
            ),
            OfferDebugRow(
                title: "Swedish house",
                action: {
                    openOffer(locale: .en_SE) {
                        QueryMock(GraphQL.QuoteBundleQuery.self) { _ in
                            .makeSwedishHouse(
                                bundleCost: .init(
                                    monthlyDiscount: .init(
                                        amount: "0",
                                        currency: "SEK"
                                    ),
                                    monthlyGross: .init(
                                        amount: "100",
                                        currency: "SEK"
                                    ),
                                    monthlyNet: .init(
                                        amount: "100",
                                        currency: "SEK"
                                    )
                                ),
                                redeemedCampaigns: []
                            )
                        }

                        MutationMock(GraphQL.SignOrApproveQuotesMutation.self) { operation in
                            .init(
                                signOrApproveQuotes: .makeSignQuoteResponse(
                                    signResponse: .makeSwedishBankIdSession(
                                        autoStartToken: "mock"
                                    )
                                )
                            )
                        }
                    }
                }
            ),
            OfferDebugRow(
                title: "Swedish house - discounted",
                action: {
                    openOffer(locale: .en_SE) {
                        QueryMock(GraphQL.QuoteBundleQuery.self) { variables in
                            .makeSwedishHouse(
                                bundleCost: .init(
                                    monthlyDiscount: .init(
                                        amount: "10",
                                        currency: "SEK"
                                    ),
                                    monthlyGross: .init(
                                        amount: "110",
                                        currency: "SEK"
                                    ),
                                    monthlyNet: .init(
                                        amount: "100",
                                        currency: "SEK"
                                    )
                                ),
                                redeemedCampaigns: [
                                    .init(displayValue: "-10 kr per month")
                                ]
                            )

                        }
                    }
                }
            ),
            OfferDebugRow(
                title: "Swedish house - discounted indefinite",
                action: {
                    openOffer(locale: .en_SE) {
                        QueryMock(GraphQL.QuoteBundleQuery.self) { variables in
                            .makeSwedishHouse(
                                bundleCost: .init(
                                    monthlyDiscount: .init(
                                        amount: "27.5",
                                        currency: "SEK"
                                    ),
                                    monthlyGross: .init(
                                        amount: "110",
                                        currency: "SEK"
                                    ),
                                    monthlyNet: .init(
                                        amount: "82.5",
                                        currency: "SEK"
                                    )
                                ),
                                redeemedCampaigns: [.init(displayValue: "-25% forever")]
                            )
                        }
                    }
                }
            ),
            OfferDebugRow(
                title: "Swedish house - discounted free months",
                action: {
                    openOffer(locale: .en_SE) {
                        QueryMock(GraphQL.QuoteBundleQuery.self) { variables in
                            .makeSwedishHouse(
                                bundleCost: .init(
                                    monthlyDiscount: .init(
                                        amount: "110",
                                        currency: "SEK"
                                    ),
                                    monthlyGross: .init(
                                        amount: "110",
                                        currency: "SEK"
                                    ),
                                    monthlyNet: .init(amount: "0", currency: "SEK")
                                ),
                                redeemedCampaigns: [
                                    .init(displayValue: "3 free months")
                                ]
                            )
                        }
                    }
                }
            ),
            OfferDebugRow(
                title: "Swedish house - discounted percentage for months",
                action: {
                    openOffer(locale: .en_SE) {
                        QueryMock(GraphQL.QuoteBundleQuery.self) { variables in
                            .makeSwedishHouse(
                                bundleCost: .init(
                                    monthlyDiscount: .init(
                                        amount: "27.5",
                                        currency: "SEK"
                                    ),
                                    monthlyGross: .init(
                                        amount: "110",
                                        currency: "SEK"
                                    ),
                                    monthlyNet: .init(
                                        amount: "82.5",
                                        currency: "SEK"
                                    )
                                ),
                                redeemedCampaigns: [
                                    .init(displayValue: "25% discount for 3 months")
                                ]
                            )
                        }
                    }
                }
            ),
            OfferDebugRow(
                title: "Norwegian bundle",
                action: {
                    openOffer(locale: .en_NO) {
                        QueryMock(GraphQL.QuoteBundleQuery.self) { variables in
                            .makeNorwegianBundle()
                        }
                    }
                }
            ),
            OfferDebugRow(
                title: "Danish bundle",
                action: {
                    openOffer(locale: .en_DK) {
                        QueryMock(GraphQL.QuoteBundleQuery.self) { variables in
                            .makeDanishBundle()
                        }

                        MutationMock(GraphQL.SignOrApproveQuotesMutation.self) { operation in
                            .init(
                                signOrApproveQuotes: .makeSignQuoteResponse(
                                    signResponse: .makeSimpleSignSession(id: "123")
                                )
                            )
                        }
                    }
                }
            ),
            OfferDebugRow(
                title: "Swedish apartment - moving flow",
                action: {
                    openOffer(locale: .en_SE) {
                        QueryMock(GraphQL.QuoteBundleQuery.self) { _ in
                            .makeSwedishApartmentMovingFlow()
                        }

                        MutationMock(GraphQL.SignOrApproveQuotesMutation.self) { operation in
                            .init(
                                signOrApproveQuotes: .makeApproveQuoteResponse(
                                    approved: true
                                )
                            )
                        }
                    }
                }
            ),
        ]

        hForm {
            hSection {
                hRow {
                    hText("Present in full screen")
                }
                .withCustomAccessory {
                    Toggle(isOn: $presentFullScreen) {

                    }
                }
                hRow {
                    hText("Prefers large titles")
                }
                .withCustomAccessory {
                    Toggle(isOn: $prefersLargeTitles) {

                    }
                }
            }
            hSection(rows, id: \.title) { row in
                hRow {
                    hText(row.title)
                }
                .onTap {
                    row.action()
                }
            }
            .withHeader {
                hText("Offer states")
            }
            hSection {
                hRow {
                    hText("Data collection - Sweden")
                }
                .onTap {
                    openDataCollection(locale: .en_SE) {
                        SubscriptionMock(
                            GraphQL.DataCollectionSubscription.self,
                            timeline: { operation in
                                TimelineEntry(
                                    after: 2,
                                    data: GraphQL.DataCollectionSubscription.Data(
                                        dataCollectionStatusV2: .init(
                                            extraInformation: .makeSwedishBankIdExtraInfo(
                                                autoStartToken: nil,
                                                swedishBankIdQrCode: nil
                                            ),
                                            status: .waitingForAuthentication
                                        )
                                    )
                                )
                            }
                        )
                    }
                }
            }
        }
    }
}

extension Debug {
    static var journey: some JourneyPresentation {
        HostingJourney(
            DebugStore.self,
            rootView: Debug()
        ) { action in
            switch action {
            case let .openOffer(fullscreen, prefersLargeTitles):
                Journey(
                    Offer(offerIDContainer: .stored, menu: nil, options: [.menuToTrailing]),
                    style: fullscreen
                        ? .modally(
                            presentationStyle: .fullScreen,
                            transitionStyle: nil,
                            capturesStatusBarAppearance: nil
                        ) : .detented(.large),
                    options: prefersLargeTitles
                        ? [
                            .defaults, .prefersLargeTitles(true),
                            .largeTitleDisplayMode(.always),
                        ]
                        : [.defaults]
                ) { _ in
                    PopJourney()
                }
            case .openDataCollection:
                DataCollection.journey(providerID: "Hedvi", providerDisplayName: "Hedvig") { _ in

                }
            }
        }
        .configureTitle("Offer Example")
    }
}

extension Debug {
    @GraphQLMockBuilder var sharedMocks: some GraphQLMock {
        MutationMock(GraphQL.ChangeStartDateMutation.self, duration: 2) { operation in
            if operation.startDate
                == Calendar.current.date(byAdding: .day, value: 3, to: Date())?
                .localDateString
            {
                throw MockError.failed
            }

            return
                GraphQL.ChangeStartDateMutation.Data(
                    editQuote: .makeCompleteQuote(startDate: operation.startDate)
                )
        }

        MutationMock(GraphQL.RedeemDiscountCodeMutation.self, duration: 2) { operation in
            if operation.code == "hello" {
                throw MockError.failed
            }

            let mockData = GraphQL.RedeemDiscountCodeMutation.Data(
                redeemCodeV2: .makeSuccessfulRedeemResult(
                    cost:
                        .init(
                            monthlyDiscount: .init(amount: "110", currency: "SEK"),
                            monthlyGross: .init(amount: "110", currency: "SEK"),
                            monthlyNet: .init(amount: "0", currency: "SEK")
                        ),
                    campaigns: [
                        .init(
                            displayValue: "3 free months"
                        )
                    ]
                )
            )

            return mockData
        }

        MutationMock(GraphQL.RemoveDiscountMutation.self, duration: 2) { _ in
            let mockData = GraphQL.RemoveDiscountMutation.Data(
                removeDiscountCode: .init(
                    cost: .init(
                        monthlyDiscount: .init(amount: "0", currency: "SEK"),
                        monthlyGross: .init(amount: "110", currency: "SEK"),
                        monthlyNet: .init(amount: "110", currency: "SEK")
                    )
                )
            )

            return mockData
        }

        SubscriptionMock(
            GraphQL.SignStatusSubscription.self,
            timeline: { operation in
                TimelineEntry(
                    after: 0,
                    data: GraphQL.SignStatusSubscription.Data(
                        signStatus: .init(
                            status: .init(
                                collectStatus: .init(
                                    status: .pending,
                                    code: "outstandingTransaction"
                                ),
                                signState: .inProgress
                            )
                        )
                    )
                )
                TimelineEntry(
                    after: 5,
                    data: GraphQL.SignStatusSubscription.Data(
                        signStatus: .init(
                            status: .init(
                                collectStatus: .init(
                                    status: .pending,
                                    code: "userSign"
                                ),
                                signState: .inProgress
                            )
                        )
                    )
                )
                TimelineEntry(
                    after: 10,
                    data: GraphQL.SignStatusSubscription.Data(
                        signStatus: .init(
                            status: .init(
                                collectStatus: .init(
                                    status: .failed,
                                    code: "userCancel"
                                ),
                                signState: .failed
                            )
                        )
                    )
                )
            }
        )

        MutationMock(GraphQL.RemoveStartDateMutation.self) { _ in
            GraphQL.RemoveStartDateMutation.Data(
                removeStartDate: .makeCompleteQuote(startDate: nil)
            )
        }

        MutationMock(GraphQL.CheckoutUpdateMutation.self, duration: 2) { operation in
            GraphQL.CheckoutUpdateMutation.Data(
                editQuote: .makeCompleteQuote(email: operation.email, ssn: operation.ssn)
            )
        }
    }
}
