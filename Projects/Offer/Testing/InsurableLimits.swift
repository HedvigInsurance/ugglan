//
//  Perils.swift
//  OfferTesting
//
//  Created by Sam Pettersson on 2021-04-22.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import hGraphQL
import Apollo

func generateInsurableLimits() -> [GraphQL.QuoteBundleQuery.Data.QuoteBundle.Quote.InsurableLimit] {
    return [
        .init(label: "Things insured to", limit: "1 000 000 SEK", description: ""),
        .init(label: "Deductible", limit: "1500 SEK", description: ""),
        .init(label: "Travel coverage", limit: "45 days", description: "")
    ]
}
