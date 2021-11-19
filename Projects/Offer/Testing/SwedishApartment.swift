import Apollo
import Foundation
import Offer
import TestingUtil
import hCore
import hGraphQL

extension GraphQL.QuoteBundleQuery.Data {
    public static func makeSwedishApartment() -> GraphQL.QuoteBundleQuery.Data {
        GraphQL.QuoteBundleQuery.Data(
            quoteBundle: .init(possibleVariations: [
                .init(
                    id: "123",
                    tag: nil,
                    bundle: .init(
                        quotes: [
                            .init(
                                id: "123",
                                displayName: "Home insurance rental",
                                detailsTable: generateDetailsTable(
                                    title: "Home insurance rental",
                                    rows: generateHomeRows()
                                ),
                                contractPerils: generatePerils(),
                                insurableLimits: generateInsurableLimits(),
                                insuranceTerms: [
                                    .init(
                                        displayName: "Terms and pre-sale information",
                                        url:
                                            "https://www.hedvig.com/no-en/terms/terms/travel.pdf",
                                        type: .termsAndConditions
                                    )
                                ]
                            )
                        ],
                        displayName: "Swedish bundle",
                        bundleCost: .init(
                            monthlyDiscount: .init(amount: "100", currency: "SEK"),
                            monthlyGross: .init(amount: "100", currency: "SEK"),
                            monthlyNet: .init(amount: "100", currency: "SEK")
                        ),
                        frequentlyAskedQuestions: generateFrequentlyAskedQuestions(),
                        inception: .makeIndependentInceptions(inceptions: [
                            .init(
                                startDate: "2020-05-10",
                                currentInsurer: .init(
                                    id: "Hedvig",
                                    displayName: "Hedvig",
                                    switchable: true
                                ),
                                correspondingQuote: .makeCompleteQuote(id: "123")
                            )
                        ]),
                        appConfiguration: .init(
                            showCampaignManagement: true,
                            showFaq: true,
                            ignoreCampaigns: false,
                            approveButtonTerminology: .confirmPurchase,
                            startDateTerminology: .startDate,
                            title: .logo,
                            gradientOption: .gradientOne
                        )
                    )
                )
            ]),
            signMethodForQuotes: GraphQL.SignMethod.swedishBankId,
            redeemedCampaigns: []
        )
    }
}
