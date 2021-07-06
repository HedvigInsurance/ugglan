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

		bag += row.append(button.alignedTo(alignment: .center))

		let removeRow = RowView()
		section.append(removeRow)
		let removeButton = Button(
			title: L10n.Offer.removeDiscountButton,
			type: .transparentLarge(textColor: .brand(.destructive))
		)
		let loadableButton = LoadableButton(button: removeButton)
		bag += removeRow.append(loadableButton.alignedTo(alignment: .center))
		removeRow.isHidden = true
		removeRow.alpha = 0

		bag += state.dataSignal.animated(style: SpringAnimationStyle.lightBounce()) { data in
			if data.redeemedCampaigns.isEmpty {
				removeRow.alpha = 0
				row.alpha = 1
				removeRow.isHidden = true
				row.isHidden = false
			} else {
				row.alpha = 0
				removeRow.alpha = 1
				row.isHidden = true
				removeRow.isHidden = false
			}
		}

		let discountsPresent = ReadWriteSignal<Bool>(false)
		bag += state.dataSignal.map { $0.redeemedCampaigns.count != 0 }.bindTo(discountsPresent)

		bag += removeButton.onTapSignal.onValue { _ in
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
		}

		bag += button.onTapSignal.onValue { _ in
<<<<<<< HEAD
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
=======
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
>>>>>>> 80f791ce14278ee361d8f5e47d87670cbe18ba67
		}

		return (section, bag)
	}
}
