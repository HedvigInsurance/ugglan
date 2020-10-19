import Apollo
import Flow
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Payment
import Presentation
import UIKit

struct OfferDiscount {
    let presentingViewController: UIViewController
    @Inject var client: ApolloClient
    @Inject var store: ApolloStore
    let redeemedCampaignsSignal = ReadWriteSignal<[GraphQL.OfferQuery.Data.RedeemedCampaign]>([])
}

extension OfferDiscount: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center

        let redeemButton = Button(title: L10n.offerAddDiscountButton, type: .outline(borderColor: .clear, textColor: .brand(.primaryText())))

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

        func handleButtonState(_ buttonView: UIView, shouldShowButton: @escaping (_ redeemedCampaigns: [GraphQL.OfferQuery.Data.RedeemedCampaign]) -> Bool) {
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
            type: .outline(borderColor: .clear, textColor: .brand(.primaryText()))
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
                    self.store.update(query: GraphQL.OfferQuery(), updater: { (data: inout GraphQL.OfferQuery.Data) in
                        data.redeemedCampaigns = result.campaigns.compactMap {
                            try? GraphQL.OfferQuery.Data.RedeemedCampaign(jsonObject: $0.jsonObject)
                        }

                        if let costFragment = result.cost?.fragments.costFragment {
                            data.insurance.cost?.fragments.costFragment = costFragment
                        }
                    })
                }

                self.presentingViewController.present(
                    applyDiscount.wrappedInCloseButton(),
                    style: .detented(.scrollViewContentSize(20), .large),
                    options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)]
                )
            }

        bag += removeButton.onTapSignal.onValue { _ in
            let alert = Alert(
                title: L10n.offerRemoveDiscountAlertTitle,
                message: L10n.offerRemoveDiscountAlertDescription,
                actions: [
                    Alert.Action(title: L10n.offerRemoveDiscountAlertCancel) {},
                    Alert.Action(title: L10n.offerRemoveDiscountAlertRemove, style: .destructive) {
                        bag += self.client.perform(mutation: GraphQL.RemoveDiscountCodeMutation()).valueSignal.compactMap { $0.removeDiscountCode }.onValue { result in
                            self.store.update(query: GraphQL.OfferQuery()) { (data: inout GraphQL.OfferQuery.Data) in
                                data.redeemedCampaigns = result.campaigns.compactMap {
                                    try? GraphQL.OfferQuery.Data.RedeemedCampaign(jsonObject: $0.jsonObject)
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
