import Apollo
import Foundation
import hGraphQL

extension GraphQL.QuoteBundleQuery.Data.QuoteBundle {
	func quoteFor(id: GraphQLID?) -> GraphQL.QuoteBundleQuery.Data.QuoteBundle.Quote? {
		self.quotes.first { quote in
			quote.id == id
		}
	}
}
