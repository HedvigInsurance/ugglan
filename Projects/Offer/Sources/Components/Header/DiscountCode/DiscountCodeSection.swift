import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct DiscountCodeSection {
	@Inject var state: OfferState
}

extension DiscountCodeSection: Presentable {
	func materialize() -> (SectionView, Disposable) {
		let section = SectionView()
		section.isHidden = true
		section.dynamicStyle = DynamicSectionStyle.brandGroupedNoBackground.rowInsets(
			UIEdgeInsets(top: 0, left: 15, bottom: 20, right: 15)
		)
		let bag = DisposeBag()

		bag += state.dataSignal.compactMap { $0.quoteBundle.appConfiguration.showCampaignManagement }
			.onValue { showCampaignManagement in
				section.isHidden = !showCampaignManagement
			}

		let row = RowView()
		section.append(row)

		let button = Button(
            title: L10n.Offer.addDiscountButton,
			type: .iconTransparent(
				textColor: .brand(.primaryText()),
				icon: .left(image: hCoreUIAssets.circularPlus.image, width: 20)
			)
		)

		let loadableButton = LoadableButton(button: button)
		bag += row.append(loadableButton.alignedTo(alignment: .center))

		bag += state.dataSignal.onValue { data in
			if data.redeemedCampaigns.isEmpty {
				button.title.value = L10n.Offer.addDiscountButton
				button.type.value = .iconTransparent(
					textColor: .brand(.primaryText()),
					icon: .left(image: hCoreUIAssets.circularPlus.image, width: 20)
				)
			} else {
                button.title.value = L10n.Offer.removeDiscountButton
				button.type.value = .transparentLarge(textColor: .brand(.destructive))
			}
		}

		let discountsPresent = ReadWriteSignal<Bool>(false)
		bag += state.dataSignal.map { $0.redeemedCampaigns.count != 0 }.bindTo(discountsPresent)

		bag += button.onTapSignal.onValue { _ in
			if discountsPresent.value {
				loadableButton.isLoadingSignal.value = true
				state.removeRedeemedCampaigns()
					.onValue { _ in
						loadableButton.isLoadingSignal.value = false
					}
					.onError { _ in
						loadableButton.isLoadingSignal.value = false
						section.viewController?
							.present(
								Alert<Void>(
                                    title: L10n.Offer.removeDiscountErrorAlertTitle,
									message:
                                        L10n.Offer.removeDiscountErrorAlertBody,
									actions: [
										.init(
											title: L10n.alertOk,
											action: { () }
										)
									]
								)
							)
					}
			} else {
				let redeemDiscount = RedeemDiscount()
				section.viewController?
					.present(
						redeemDiscount.wrappedInCloseButton(),
						style: .detented(.scrollViewContentSize(20), .large),
						options: [
							.defaults, .prefersLargeTitles(false),
							.largeTitleDisplayMode(.never),
						]
					)
			}
		}

		return (section, bag)
	}
}
