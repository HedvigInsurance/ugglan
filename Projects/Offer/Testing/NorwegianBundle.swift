import Apollo
import Foundation
import hCore
import hGraphQL
import Offer
import TestingUtil

func generateTravelRows() -> [GraphQL.QuoteBundleQuery.Data.QuoteBundle.Quote.DetailsTable.Section.Row] {
    [
        .init(title: "Co-insured", subtitle: nil, value: "You + 2")
    ]
}

func generateHomeRows() -> [GraphQL.QuoteBundleQuery.Data.QuoteBundle.Quote.DetailsTable.Section.Row] {
    [
        .init(title: "Street", subtitle: nil, value: "An address"),
        .init(title: "Postal code", subtitle: nil, value: "111 44"),
        .init(title: "Co-insured", subtitle: nil, value: "You + 2")
    ]
}

func generateDetailsTable(title: String, rows: [GraphQL.QuoteBundleQuery.Data.QuoteBundle.Quote.DetailsTable.Section.Row]) -> GraphQL.QuoteBundleQuery.Data.QuoteBundle.Quote.DetailsTable {
    return .init(
        title: title,
        sections: [
            .init(
                title: "Details",
                rows: rows
            )
        ]
    )
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
                        detailsTable: generateDetailsTable(title: "Innboforsikring", rows: generateHomeRows())
                    ),
                    .init(
                        id: "123",
                        currentInsurer: nil,
                        firstName: "Hedvig",
                        lastName: "Hedvigsen",
                        displayName: "Reiseforsikring",
                        detailsTable: generateDetailsTable(title: "Reiseforsikring", rows: generateTravelRows())
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
