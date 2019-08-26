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

struct OfferDiscount {
    let containerScrollView: UIScrollView
    let presentingViewController: UIViewController
    let client: ApolloClient
    let store: ApolloStore
    let redeemedCampaignsSignal = ReadWriteSignal<[OfferQuery.Data.RedeemedCampaign]>([])

    init(
        containerScrollView: UIScrollView,
        presentingViewController: UIViewController,
        client: ApolloClient = ApolloContainer.shared.client,
        store: ApolloStore = ApolloContainer.shared.store
    ) {
        self.containerScrollView = containerScrollView
        self.presentingViewController = presentingViewController
        self.client = client
        self.store = store
    }
}

extension OfferDiscount: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIStackView()
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 30, right: 0)
        view.axis = .vertical
        view.alignment = .center

        bag += containerScrollView.contentOffsetSignal.onValue { contentOffset in
            view.transform = CGAffineTransform(
                translationX: 0,
                y: (contentOffset.y / 5)
            )
        }

        let redeemButton = Button(title: String(key: .OFFER_ADD_DISCOUNT_BUTTON), type: .outline(borderColor: .white, textColor: .white))

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
                return redeemedCampaigns.isEmpty
            }
        }

        let removeButton = Button(
            title: String(key: .OFFER_REMOVE_DISCOUNT_BUTTON),
            type: .outline(borderColor: .white, textColor: .white)
        )
        bag += view.add(removeButton) { buttonView in
            handleButtonState(buttonView) { redeemedCampaigns -> Bool in
                return !redeemedCampaigns.isEmpty
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
                    DraggableOverlay(
                        presentable: applyDiscount,
                        presentationOptions: [.defaults, .prefersNavigationBarHidden(true)]
                    )
                ).disposable
            }

        bag += removeButton.onTapSignal.onValue { _ in
            let alert = Alert(
                title: String(key: .OFFER_REMOVE_DISCOUNT_ALERT_TITLE),
                message: String(key: .OFFER_REMOVE_DISCOUNT_ALERT_DESCRIPTION),
                actions: [
                    Alert.Action(title: String(key: .OFFER_REMOVE_DISCOUNT_ALERT_CANCEL)) {},
                    Alert.Action(title: String(key: .OFFER_REMOVE_DISCOUNT_ALERT_REMOVE), style: .destructive) {
                        bag += self.client.perform(mutation: RemoveDiscountCodeMutation()).valueSignal.compactMap { $0.data?.removeDiscountCode }.onValue({ result in
                            self.store.update(query: OfferQuery()) { (data: inout OfferQuery.Data) in
                                data.redeemedCampaigns = result.campaigns.compactMap {
                                    try? OfferQuery.Data.RedeemedCampaign(jsonObject: $0.jsonObject)
                                }
                                data.insurance.cost?.fragments.costFragment = result.cost.fragments.costFragment
                            }
                        })
                    },
                ]
            )

            self.presentingViewController.present(alert)
        }

        return (view, bag)
    }
}
