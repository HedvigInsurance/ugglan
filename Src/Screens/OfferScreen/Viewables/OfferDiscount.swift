//
//  OfferDiscount.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-09.
//

import Flow
import Foundation
import UIKit
import Presentation
import Apollo

struct OfferDiscount {
    let containerScrollView: UIScrollView
    let presentingViewController: UIViewController
    let client: ApolloClient
    let store: ApolloStore
    let referralInformationSignal = ReadWriteSignal<OfferQuery.Data.ReferralInformation?>(nil)
    
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
        bag += view.addArranged(redeemButton) { buttonView in
            buttonView.animationSafeIsHidden = true
            
            bag += referralInformationSignal.compactMap { $0 }.animated(style: SpringAnimationStyle.mediumBounce()) { referralInformation in
                if referralInformation.campaign.incentive != nil {
                    buttonView.animationSafeIsHidden = true
                    buttonView.alpha = 0
                } else {
                    buttonView.animationSafeIsHidden = false
                    buttonView.alpha = 1
                }
            }
            
            let innerBag = DisposeBag()

            buttonView.transform = CGAffineTransform(scaleX: 0, y: 0).concatenating(CGAffineTransform(translationX: 0, y: -30))
            buttonView.alpha = 0

            innerBag += Signal(after: 1.2)
                .animated(style: SpringAnimationStyle.mediumBounce()) { _ in
                    buttonView.alpha = 1
                    buttonView.transform = CGAffineTransform.identity
                    innerBag.dispose()
                }
        }
        
        let removeButton = Button(
            title: String(key: .OFFER_REMOVE_DISCOUNT_BUTTON),
            type: .outline(borderColor: .white, textColor: .white)
        )
        bag += view.addArranged(removeButton) { buttonView in
            buttonView.animationSafeIsHidden = true
            
            bag += referralInformationSignal.compactMap { $0 }.animated(style: SpringAnimationStyle.mediumBounce()) { referralInformation in
                if referralInformation.campaign.incentive != nil {
                    buttonView.animationSafeIsHidden = false
                    buttonView.alpha = 1
                } else {
                    buttonView.animationSafeIsHidden = true
                    buttonView.alpha = 0
                }
            }
            
            let innerBag = DisposeBag()

            buttonView.transform = CGAffineTransform(scaleX: 0, y: 0).concatenating(CGAffineTransform(translationX: 0, y: -30))
            buttonView.alpha = 0

            innerBag += Signal(after: 1.2)
                .animated(style: SpringAnimationStyle.mediumBounce()) { _ in
                    buttonView.alpha = 1
                    buttonView.transform = CGAffineTransform.identity
                    innerBag.dispose()
                }
        }
        
        bag += redeemButton
            .onTapSignal
            .onValue { _ in
            let applyDiscount = ApplyDiscount()
                
                bag += applyDiscount.didRedeemValidCodeSignal.onValue { result in
                    print(result)
                    
//                    self.store.update(query: OfferQuery(), updater: { (data: inout OfferQuery.Data) in
//                        data.insurance.cost = OfferQuery.Data.Insurance.Cost(
//                            monthlyGross: OfferQuery.Data.Insurance.Cost.MonthlyGross(
//                                amount: result.cost.monthlyGross.amount,
//                                currency: result.cost.monthlyGross.currency
//                            ),
//                            monthlyNet: OfferQuery.Data.Insurance.Cost.MonthlyNet(
//                                amount: result.cost.monthlyNet.amount,
//                                currency: result.cost.monthlyNet.currency
//                            ),
//                            monthlyDiscount: OfferQuery.Data.Insurance.Cost.MonthlyDiscount(
//                                amount: result.cost.monthlyDiscount.amount,
//                                currency: result.cost.monthlyDiscount.currency
//                            )
//                        )
//                    })
                    
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
                    Alert.Action(title: String(key: .OFFER_REMOVE_DISCOUNT_ALERT_REMOVE)) {
                        bag += self.client.perform(mutation: RemoveDiscountCodeMutation()).valueSignal.onValue({ _ in
                            self.store.update(query: OfferQuery()) { (data: inout OfferQuery.Data) in
                                data.referralInformation.campaign.incentive = nil
                            }
                        })
                    }
                ]
            )
            
            self.presentingViewController.present(alert)
        }

        return (view, bag)
    }
}
