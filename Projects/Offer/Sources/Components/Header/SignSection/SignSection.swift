import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct SignSection {
	@Inject var state: OfferState
}

extension SignSection: Presentable {
	func materialize() -> (SectionView, Disposable) {
		let section = SectionView()
		let bag = DisposeBag()

		let row = RowView()
		section.append(row)

		bag += state.dataSignal.onValueDisposePrevious { data in
			let innerBag = DisposeBag()

			switch data.signMethodForQuotes {
			case .swedishBankId:
				let signButton = Button(
					title: L10n.offerSignButton,
					type: .standardIcon(
						backgroundColor: .brand(.secondaryButtonBackgroundColor),
						textColor: .brand(.secondaryButtonTextColor),
						icon: .left(image: hCoreUIAssets.bankIdLogo.image, width: 20)
					)
				)

				innerBag += signButton.onTapSignal.compactMap { _ in row.viewController }
					.onValue { viewController in
						viewController.present(
							SwedishBankIdSign(),
							style: .detented(.medium),
							options: [
								.defaults, .prefersLargeTitles(true),
								.largeTitleDisplayMode(.always),
							]
						)
					}

				innerBag += row.append(signButton)
			case .norwegianBankId, .danishBankId:
				break
			case .simpleSign:
				let signButton = Button(
					title: L10n.offerSignButton,
					type: .standard(
						backgroundColor: .brand(.secondaryButtonBackgroundColor),
						textColor: .brand(.secondaryButtonTextColor)
					)
				)

				innerBag += signButton.onTapSignal.compactMap { _ in row.viewController }
					.onValue { viewController in
						viewController.present(
							Checkout().wrappedInCloseButton(),
							style: .detented(.large),
							options: [
								.defaults, .prefersLargeTitles(true),
								.largeTitleDisplayMode(.always),
							]
						)
					}

				innerBag += row.append(signButton)
			case .approveOnly:
				let signButton = Button(
					title: L10n.offerApproveChanges,
					type: .standard(
						backgroundColor: .brand(.secondaryButtonBackgroundColor),
						textColor: .brand(.secondaryButtonTextColor)
					)
				)

				let loadableSignButton = LoadableButton(button: signButton)

				innerBag += loadableSignButton.onTapSignal
					.onValue { _ in
						loadableSignButton.isLoadingSignal.value = true
						state.signQuotes()
							.onError { _ in
								loadableSignButton.isLoadingSignal.value = false
							}
					}

				innerBag += row.append(loadableSignButton)
			case .__unknown(_):
				break
			}

			return innerBag
		}

		return (section, bag)
	}
}
