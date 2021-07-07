//
//  QuoteBundle+.swift
//  Offer
//
//  Created by Sam Pettersson on 2021-07-07.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import hGraphQL
import Apollo

extension GraphQL.QuoteBundleQuery.Data.QuoteBundle {
    func quoteFor(id: GraphQLID?) -> GraphQL.QuoteBundleQuery.Data.QuoteBundle.Quote? {
        self.quotes.first { quote in
            quote.id == id
        }
    }
}
