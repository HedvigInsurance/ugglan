import Apollo
import Foundation
import SwiftUI
import hCore
import hGraphQL

@available(iOS 13, *) struct ExchangeToken: View {
	let onToken: (_ token: String, _ locale: Localization.Locale) -> Void

	init(onToken: @escaping (_ token: String, _ locale: Localization.Locale) -> Void) { self.onToken = onToken }

	@State var paymentUrl: String = ""
	@Inject var client: ApolloClient

	@State private var selectedLocale = Localization.Locale.currentLocale

	let locales = Localization.Locale.allCases
	var pickerStyle: some PickerStyle {
		#if targetEnvironment(macCatalyst)
			return MenuPickerStyle()
		#else
			return WheelPickerStyle()
		#endif
	}

	var body: some View {
		Form {
			TextField("Payment url", text: $paymentUrl)
			Section {
				Picker("Locale", selection: $selectedLocale) {
					ForEach(locales, id: \.self) { Text($0.code) }
				}
				.pickerStyle(pickerStyle)
			}
			SwiftUI.Button("Exchange") {
				let afterHashbang = paymentUrl.split(separator: "#").last
				let exchangeToken =
					afterHashbang?.replacingOccurrences(of: "exchange-token=", with: "") ?? ""

				client.perform(
					mutation: GraphQL.ExchangeTokenMutation(
						exchangeToken: exchangeToken.removingPercentEncoding ?? ""
					)
				)
				.onValue { response in
					guard let token = response.exchangeToken.asExchangeTokenSuccessResponse?.token
					else { return }
					onToken(token, selectedLocale)
				}
			}
		}
	}
}
