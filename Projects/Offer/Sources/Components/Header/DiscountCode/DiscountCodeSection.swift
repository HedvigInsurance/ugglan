import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct DiscountCodeSection {}

extension DiscountCodeSection: Presentable {
    func materialize() -> (SectionView, Disposable) {
        let section = SectionView()
        section.isHidden = true
        section.dynamicStyle = DynamicSectionStyle.brandGroupedNoBackground.rowInsets(
            UIEdgeInsets(top: 0, left: 15, bottom: 20, right: 15)
        )
        let bag = DisposeBag()

        let store: OfferStore = self.get()

        bag += store.stateSignal.compactMap { $0.offerData?.quoteBundle.appConfiguration.showCampaignManagement }
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

        func updateVisibility(data: OfferBundle) {
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

        bag += store.stateSignal.compactMap { $0.offerData }
            .captureFirstValue { data in
                updateVisibility(data: data)
            }
            .animated(style: SpringAnimationStyle.lightBounce()) { data in
                updateVisibility(data: data)
            }

        let discountsPresent = ReadWriteSignal<Bool>(false)
        bag += store.stateSignal.map { $0.offerData?.redeemedCampaigns.count != 0 }.bindTo(discountsPresent)

        bag += removeButton.onTapSignal.onValueDisposePrevious { _ in
            let innerBag = DisposeBag()
            
            store.send(.removeRedeemedCampaigns)
            loadableButton.isLoadingSignal.value = true
            innerBag += store.onAction(
                .removeRedeemedCampaigns,
                {
                    loadableButton.isLoadingSignal.value = false
                }
            )

            innerBag += store.onAction(
                .failed(event: .removeCampaigns),
                {
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
            )
            
            return innerBag
        }

        bag += button.onTapSignal.onValue { _ in
            let redeemDiscount = RedeemDiscount()
            section.viewController?
                .present(
                    redeemDiscount.wrappedInCloseButton(),
                    style: .detented(.scrollViewContentSize, .large),
                    options: [
                        .defaults, .prefersLargeTitles(false),
                        .largeTitleDisplayMode(.never),
                    ]
                )
        }

        return (section, bag)
    }
}
