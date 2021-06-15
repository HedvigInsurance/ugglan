import Apollo
import Foundation
import hCore
import hGraphQL
import Offer
import TestingUtil

public extension GraphQL.QuoteBundleQuery.Data {
    static func makeSwedishApartment() -> GraphQL.QuoteBundleQuery.Data {
        GraphQL.QuoteBundleQuery.Data(
            quoteBundle: .init(
                quotes: [
                    .init(
                        id: "123",
                        currentInsurer: nil,
                        firstName: "Hedvig",
                        lastName: "Hedvigsen",
                        displayName: "Home insurance rental",
                        detailsTable: generateDetailsTable(title: "Home insurance rental", rows: generateHomeRows()), perils: generatePerils(),
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
                bundleCost: .init(
                    monthlyGross: .init(amount: "100", currency: "SEK"),
                    monthlyDiscount: .init(amount: "100", currency: "SEK"),
                    monthlyNet: .init(amount: "100", currency: "SEK")
                ),
                frequentlyAskedQuestions: generateFrequentlyAskedQuestions(),
                inception: .makeIndependentInceptions(inceptions: [
                    .init(startDate: "2020-05-10", correspondingQuote: .makeCompleteQuote(id: "123"))
                ])
            ),
            signMethodForQuotes: GraphQL.SignMethod.swedishBankId,
            redeemedCampaigns: []
        )
    }
}
