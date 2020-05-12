//
//  OfferDiscount.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-09.
//

import Apollo
import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

struct OfferDiscount {
    let presentingViewController: UIViewController
    @Inject var client: ApolloClient
    @Inject var store: ApolloStore
    let redeemedCampaignsSignal = ReadWriteSignal<[OfferQuery.Data.RedeemedCampaign]>([])
}

extension OfferDiscount: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center

        let redeemButton = Button(title: L10n.offerAddDiscountButton, type: .outline(borderColor: .transparent, textColor: .primaryText))

        view.snp.makeConstraints { make in
            make.height.equalTo(redeemButton.type.value.height + view.layoutMargins.top + view.layoutMargins.bottom)
        }

        func outState(_ view: UIView) {
            view.isUserInteractionEnabled = false
            view.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001).concatenating(CGAffineTransform(translationX: 0, y: -30))
            view.alpha = 0
        }

        func inState(_ view: UIView) {
            view.isUserInteractionEnabled = true
            view.transform = CGAffineTransform.identity
            view.alpha = 1
        }

        let dataSignal = redeemedCampaignsSignal.compactMap { $0 }

        func handleButtonState(_ buttonView: UIView, shouldShowButton: @escaping (_ redeemedCampaigns: [OfferQuery.Data.RedeemedCampaign]) -> Bool) {
            outState(buttonView)

            bag += dataSignal.take(first: 1).animated(style: SpringAnimationStyle.mediumBounce(delay: 1)) { redeemedCampaigns in
                if shouldShowButton(redeemedCampaigns) {
                    inState(buttonView)
                } else {
                    outState(buttonView)
                }
            }

            bag += dataSignal.skip(first: 1).animated(style: SpringAnimationStyle.mediumBounce()) { redeemedCampaigns in
                if shouldShowButton(redeemedCampaigns) {
                    inState(buttonView)
                } else {
                    outState(buttonView)
                }
            }
        }

        bag += view.add(redeemButton) { buttonView in
            handleButtonState(buttonView) { redeemedCampaigns -> Bool in
                redeemedCampaigns.isEmpty
            }
        }

        let removeButton = Button(
            title: L10n.offerRemoveDiscountButton,
            type: .outline(borderColor: .transparent, textColor: .primaryText)
        )
        bag += view.add(removeButton) { buttonView in
            handleButtonState(buttonView) { redeemedCampaigns -> Bool in
                !redeemedCampaigns.isEmpty
            }
        }

        bag += redeemButton
            .onTapSignal
            .onValue { _ in
                let applyDiscount = ApplyDiscount()

                bag += applyDiscount.didRedeemValidCodeSignal.onValue { result in
                    self.store.update(query: OfferQuery(), updater: { (data: inout OfferQuery.Data) in
                        data.redeemedCampaigns = result.campaigns.compactMap {
                            try? OfferQuery.Data.RedeemedCampaign(jsonObject: $0.jsonObject)
                        }
                        data.insurance.cost?.fragments.costFragment = result.cost.fragments.costFragment
                    })
                }

                bag += self.presentingViewController.present(
                    applyDiscount.withCloseButton,
                    style: .modally()
                ).disposable
            }

        bag += removeButton.onTapSignal.onValue { _ in
            let alert = Alert(
                title: L10n.offerRemoveDiscountAlertTitle,
                message: L10n.offerRemoveDiscountAlertDescription,
                actions: [
                    Alert.Action(title: L10n.offerRemoveDiscountAlertCancel) {},
                    Alert.Action(title: L10n.offerRemoveDiscountAlertRemove, style: .destructive) {
                        bag += self.client.perform(mutation: RemoveDiscountCodeMutation()).valueSignal.compactMap { $0.data?.removeDiscountCode }.onValue { result in
                            self.store.update(query: OfferQuery()) { (data: inout OfferQuery.Data) in
                                data.redeemedCampaigns = result.campaigns.compactMap {
                                    try? OfferQuery.Data.RedeemedCampaign(jsonObject: $0.jsonObject)
                                }
                                data.insurance.cost?.fragments.costFragment = result.cost.fragments.costFragment
                            }
                        }
                    },
                ]
            )

            self.presentingViewController.present(alert)
        }

        return (view, bag)
    }
}
