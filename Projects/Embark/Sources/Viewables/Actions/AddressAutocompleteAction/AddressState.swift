import Apollo
import Flow
import Foundation
import hCore
import hGraphQL

class AddressState {
	@Inject var client: ApolloClient

	func getSuggestions(searchTerm: String) -> Future<GraphQL.AddressAutocompleteQuery.Data> {
		return self.client.fetch(query: GraphQL.AddressAutocompleteQuery(input: searchTerm, type: .street))
	}
}
