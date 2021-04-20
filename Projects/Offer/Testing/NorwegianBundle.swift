import Apollo
import Foundation
import hCore
import hGraphQL
import Offer
import TestingUtil

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
                        quoteDetails: GraphQL.QuoteBundleQuery.Data.QuoteBundle.Quote.QuoteDetail.makeNorwegianHomeContentsDetails(
                            street: "Guleböjs vegen 12",
                            zipCode: "11111",
                            coInsured: 2,
                            livingSpace: 100,
                            isYouth: false,
                            norwegianHomeType: .own
                        )
                    ),
                    .init(
                        id: "123",
                        currentInsurer: nil,
                        firstName: "Hedvig",
                        lastName: "Hedvigsen",
                        quoteDetails: GraphQL.QuoteBundleQuery.Data.QuoteBundle.Quote.QuoteDetail.makeNorwegianTravelDetails(
                            coInsured: 2,
                            isYouth: false
                        )
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
