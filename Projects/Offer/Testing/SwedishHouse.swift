import Apollo
import Foundation
import hCore
import hGraphQL
import Offer
import TestingUtil

public extension JSONObject {
    static func makeSwedishHouse() -> JSONObject {
        GraphQL.QuoteBundleQuery.Data.init(
            quoteBundle: .init(
                quotes: [
                    .init(
                        id: "123",
                        currentInsurer: nil,
                        firstName: "Hedvig",
                        lastName: "Hedvigsen",
                        displayName: "Apartment",
                        detailsTable: .init(
                            title: "House",
                            sections: [
                                .init(title: "Details", rows: generateHomeRows()),
                                .init(title: "Extra buildings", rows: [
                                    .init(title: "Sauna", subtitle: "Has water connected", value: "40 m2"),
                                    .init(title: "Garage", subtitle: nil, value: "22 m2")
                                ])
                            ]
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
