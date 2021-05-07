import Apollo
import Foundation
import hCore
import hGraphQL
import Offer
import TestingUtil

public extension JSONObject {
    static func makeSwedishHouse(
        bundleCost: GraphQL.QuoteBundleQuery.Data.QuoteBundle.BundleCost,
        redeemedCampaigns: [GraphQL.QuoteBundleQuery.Data.RedeemedCampaign]
    ) -> JSONObject {
        GraphQL.QuoteBundleQuery.Data.init(
            quoteBundle: .init(
                quotes: [
                    .init(
                        id: "123",
                        currentInsurer: nil,
                        firstName: "Hedvig",
                        lastName: "Hedvigsen",
                        displayName: "House insurance",
                        detailsTable: .init(
                            title: "House insurance",
                            sections: [
                                .init(title: "Details", rows: generateHomeRows()),
                                .init(title: "Extra buildings", rows: [
                                    .init(title: "Sauna", subtitle: "Has water connected", value: "40 m2"),
                                    .init(title: "Garage", subtitle: nil, value: "22 m2")
                                ])
                            ]
                        ),
                        perils: generatePerils(),
                        insurableLimits: generateInsurableLimits(),
                        insuranceTerms: [
                            .init(
                                displayName: "Terms and pre-sale information",
                                url: "https://www.hedvig.com/no-en/terms/terms/travel.pdf",
                                type: .termsAndConditions
                            )
                        ]
                    )
                ],
                bundleCost: bundleCost,
                frequentlyAskedQuestions: generateFrequentlyAskedQuestions()
            ),
            redeemedCampaigns: redeemedCampaigns
        ).jsonObject
    }
}
