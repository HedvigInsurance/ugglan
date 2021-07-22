import Apollo
import Flow
import Foundation
import hCore
import hGraphQL

typealias SearchType = GraphQL.AddressAutocompleteType
typealias SuggestionData = GraphQL.AddressAutocompleteQuery.Data
typealias AddressSuggestion = SuggestionData.AutoCompleteAddress

class AddressState {
	@Inject var client: ApolloClient

	let pickedSuggestionSignal: ReadWriteSignal<AddressSuggestion?> = ReadWriteSignal(nil)

	func getSuggestions(searchTerm: String, suggestion: AddressSuggestion?) -> Future<[AddressSuggestion]> {
		let queryParams = getApiQueryParams(searchTerm, suggestion)
		return self.client
			.fetch(
				query: GraphQL.AddressAutocompleteQuery(
					input: queryParams.apiQuery,
					type: queryParams.searchType
				)
			)
			.map { $0.autoCompleteAddress }
	}

	func getApiQueryParams(
		_ searchTerm: String,
		_ suggestion: AddressSuggestion?
	) -> (apiQuery: String, searchType: SearchType) {
		if let suggestion = suggestion {
			if suggestion.city == nil {
				// Refine search after selecting a suggested street name
				return (searchTerm, .building)
			}

			if let city = suggestion.city, let postalCode = suggestion.postalCode,
				isMatchingStreetName(searchTerm, suggestion)
			{
				// Refine search after selecting a specific building (floor & apartment)
				return ("\(searchTerm), , \(postalCode) \(city)", .apartment)
			}
		}

		return (searchTerm, .street)
	}

	func formatAddressLine(from suggestion: AddressSuggestion) -> String {
		if let streetName = suggestion.streetName, let streetNumber = suggestion.streetNumber {
			var displayAddress = "\(streetName) \(streetNumber)"
			if let floor = suggestion.floor {
				displayAddress += ", \(floor)"
			}
			if let apartment = suggestion.apartment {
				displayAddress += ", \(apartment)"
			}
			return displayAddress
		}

		return suggestion.address
	}

	func isMatchingStreetName(_ searchTerm: String, _ suggestion: AddressSuggestion?) -> Bool {
		guard let streetName = suggestion?.streetName else { return false }
		return searchTerm.starts(with: streetName)
	}
}
