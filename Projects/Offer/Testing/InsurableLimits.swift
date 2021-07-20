import Apollo
import Foundation
import hGraphQL

func generateInsurableLimits() -> [GraphQL.QuoteBundleQuery.Data.QuoteBundle.Quote.InsurableLimit] {
	return [
		.init(label: "Things insured to", limit: "1 000 000 SEK", description: ""),
		.init(label: "Deductible", limit: "1500 SEK", description: ""),
		.init(label: "Travel coverage", limit: "45 days", description: ""),
	]
}
