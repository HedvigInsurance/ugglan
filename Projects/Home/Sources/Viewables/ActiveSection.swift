import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct ActiveSection { @Inject var client: ApolloClient }

extension ActiveSection: Presentable {
	func materialize() -> (SectionView, Disposable) {
		let bag = DisposeBag()
		let section = SectionView()

		let store: HomeStore = self.get()

		section.dynamicStyle = .brandGrouped(separatorType: .none)

		var label = MultilineLabel(value: "", style: .brand(.largeTitle(color: .primary)))
		bag += section.append(label)

		client.fetch(query: GraphQL.HomeQuery())
			.onValue { data in label.value = L10n.HomeTab.welcomeTitle(data.member.firstName ?? "") }

		section.appendSpacing(.top)

		let claimButton = Button(
			title: L10n.HomeTab.claimButtonText,
			type: .standard(
				backgroundColor: .brand(.secondaryButtonBackgroundColor),
				textColor: .brand(.secondaryButtonTextColor)
			)
		)
		bag += section.append(claimButton)
		bag += claimButton.onTapSignal.onValue {
			store.send(.openClaims)
		}

		section.appendSpacing(.inbetween)

		let howClaimsWorkButton = Button(
			title: L10n.ClaimsExplainer.title,
			type: .iconTransparent(
				textColor: .brand(.primaryTintColor),
				icon: .left(image: hCoreUIAssets.infoSmall.image, width: .smallIconWidth)
			)
		)
		bag += section.append(howClaimsWorkButton.alignedTo(alignment: .center))
		bag += howClaimsWorkButton.onTapSignal.compactMap { section.viewController }
			.onValue { viewController in
				var pager = Pager(
					title: L10n.ClaimsExplainer.title,
					buttonContinueTitle: L10n.ClaimsExplainer.buttonNext,
					buttonDoneTitle: L10n.ClaimsExplainer.buttonStartClaim,
					pages: []
				) { viewController in
					store.send(.openClaims)
					return Future(.forever)
				}
				viewController.present(pager)

				client.fetch(
					query: GraphQL.HowClaimsWorkQuery(
						locale: Localization.Locale.currentLocale.asGraphQLLocale()
					)
				)
				.onValue { data in
					pager.pages = data.howClaimsWork.map {
						ContentIconPagerItem(
							title: nil,
							paragraph: $0.body,
							icon: $0.illustration.fragments.iconFragment
						)
						.pagerItem
					}
				}
			}

		bag += section.append(ConnectPaymentCard())
		bag += section.append(RenewalCard())

		section.appendSpacing(.custom(80))

		bag += section.append(CommonClaimsCollection())

		return (section, bag)
	}
}
