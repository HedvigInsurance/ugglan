import Apollo
import Foundation
import hCore
import hGraphQL
import Offer
import TestingUtil

func generateDetailsTable() -> [GraphQL.QuoteBundleQuery.Data.QuoteBundle.Quote.DetailsTable] {
    return [
        .init(label: "Street", value: "An address"),
        .init(label: "Postal code", value: "111 44"),
        .init(label: "Co-insured", value: "You + 2")
    ]
}

public extension JSONObject {
    static func makeNorwegianBundle() -> JSONObject {
        GraphQL.QuoteBundleQuery.Data.init(
            quoteBundle: .init(
                quotes: [
                    .init(
                        id: "123",
                        currentInsurer: nil,
                        firstName: "Hedvig",
                        lastName: "Hedvigsen",
                        displayName: "Innboforsikring",
                        detailsTable: generateDetailsTable(),
                        perils: generatePerils(),
                        insurableLimits: generateInsurableLimits(),
                        insuranceTerms: [
                            .init(
                                displayName: "Terms and pre-sale information",
                                url: "https://www.hedvig.com/no-en/terms/terms/travel.pdf",
                                type: .termsAndConditions
                            ),
                            .init(
                                displayName: "General terms",
                                url: "https://www.hedvig.com/no-en/terms",
                                type: .generalTerms
                            ),
                            .init(
                                displayName: "EU standard pre-sale information",
                                url: "https://www.hedvig.com/no-en/terms",
                                type: .preSaleInfoEuStandard
                            )
                        ]
                    ),
                    .init(
                        id: "123",
                        currentInsurer: nil,
                        firstName: "Hedvig",
                        lastName: "Hedvigsen",
                        displayName: "Reiseforsikring",
                        detailsTable: [
                            .init(label: "Co-insured", value: "You + 2")
                        ],
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
                bundleCost: .init(
                    monthlyGross: .init(amount: "100", currency: "SEK"),
                    monthlyDiscount: .init(amount: "100", currency: "SEK"),
                    monthlyNet: .init(amount: "100", currency: "SEK")
                )
            )
        ).jsonObject
    }
}
