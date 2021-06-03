import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import SafariServices
import UIKit

struct OfferTermsLinks { @Inject var client: ApolloClient }

extension OfferTermsLinks: Viewable {
	func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
		let bag = DisposeBag()
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = 15
		stackView.edgeInsets = UIEdgeInsets(horizontalInset: 16, verticalInset: 0)

		func openUrl(_ url: URL) {
			stackView.viewController?
				.present(SFSafariViewController(url: url), animated: true, completion: nil)
		}

		bag += client.fetch(query: GraphQL.OfferQuery()).valueSignal.compactMap { $0.lastQuoteOfMember }
			.onValueDisposePrevious { lastQuoteOfMember in let innerBag = DisposeBag()

				lastQuoteOfMember.asCompleteQuote?.insuranceTerms
					.forEach { term in

						var url: URL?

						let isSwedishMarket = Localization.Locale.currentLocale.market == .se

						if let termType = term.type, termType == .termsAndConditions,
							isSwedishMarket {
							url = URL(string: "https://www.hedvig.com/se/villkor")
						} else {
							url = URL(string: term.url)
						}

						if let url = url {
							let button = Button(
								title: term.displayName,
								type: .standard(
									backgroundColor: .lightGray,
									textColor: .black
								)
							)

							innerBag += button.onTapSignal.onValue { _ in openUrl(url) }

							innerBag += stackView.addArranged(
								button.wrappedIn(UIStackView())
							)
						}
					}

				if let privacyPolicyUrl = URL(string: L10n.privacyPolicyUrl) {
					let button = Button(
						title: L10n.offerPrivacyPolicy,
						type: .standard(backgroundColor: .lightGray, textColor: .black)
					)

					innerBag += button.onTapSignal.onValue { _ in openUrl(privacyPolicyUrl) }
				}

				return innerBag
			}

		return (stackView, bag)
	}
}
