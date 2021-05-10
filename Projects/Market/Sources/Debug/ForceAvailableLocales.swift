import Apollo
import Foundation
import SwiftUI
import hCore
import hGraphQL

@available(iOS 13, *) public struct ForceAvailableLocales: View {
	public init() {}
	@Inject var client: ApolloClient
	@Inject var store: ApolloStore

	@State private var availableLocales: [GraphQL.Locale] = [] {
		didSet {
			store.update(query: GraphQL.MarketQuery()) { (data: inout GraphQL.MarketQuery.Data) in
				data.availableLocales = availableLocales
			}
		}
	}

	func bindingFor(_ locale: GraphQL.Locale) -> Binding<Bool> {
		Binding<Bool>(
			get: { availableLocales.contains(locale) },
			set: { newValue in
				if newValue {
					availableLocales.append(locale)
				} else {
					availableLocales.removeAll { localeToRemove in locale == localeToRemove }
				}
			}
		)
	}
	public var body: some View {
		ForEach(GraphQL.Locale.allCases, id: \.self) { locale in
			Toggle(isOn: bindingFor(locale)) { Text(locale.rawValue) }.toggleStyle(CheckmarkToggleStyle())
		}
		.onAppear(perform: {
			client.fetch(query: GraphQL.MarketQuery())
				.onValue { data in availableLocales = data.availableLocales }
		})
	}
}
