import Apollo
import Foundation
import Offer
import TestingUtil
import hCore
import hGraphQL

extension GraphQL.QuoteBundleQuery.Data {
    public static func makeSwedishHouse(
        bundleCost: GraphQL.QuoteBundleQuery.Data.QuoteBundle.PossibleVariation.Bundle.BundleCost,
        redeemedCampaigns: [GraphQL.QuoteBundleQuery.Data.RedeemedCampaign]
    ) -> GraphQL.QuoteBundleQuery.Data {
        GraphQL.QuoteBundleQuery.Data(
            quoteBundle: .init(
                possibleVariations: [
                    .init(
                        id: "123",
                        tag: nil,
                        bundle: .init(
                            quotes: [
                                .init(
                                    id: "123",
                                    displayName: "House insurance",
                                    detailsTable: .init(
                                        title: "House insurance",
                                        sections: [
                                            .init(title: "Details", rows: generateHomeRows()),
                                            .init(
                                                title: "Extra buildings",
                                                rows: [
                                                    .init(
                                                        title: "Sauna",
                                                        subtitle: "Has water connected",
                                                        value: "40 m2"
                                                    ),
                                                    .init(
                                                        title: "Garage",
                                                        subtitle: nil,
                                                        value: "22 m2"
                                                    ),
                                                ]
                                            ),
                                        ]
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
                            bundleCost: bundleCost,
                            frequentlyAskedQuestions: generateFrequentlyAskedQuestions(),
                            inception: .makeIndependentInceptions(inceptions: [
                                .init(
                                    startDate: "2020-05-10",
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
                                gradientOption: .gradientTwo
                            )
                        )
                    )
                ]
            ),
            signMethodForQuotes: GraphQL.SignMethod.swedishBankId,
            redeemedCampaigns: redeemedCampaigns
        )
    }
}
