import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct RedeemDiscount {}

extension RedeemDiscount: Presentable {
    public func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        viewController.title = L10n.referralAddcouponHeadline

        let store: OfferStore = self.get()

        let bag = DisposeBag()

        let form = FormView()
        form.dynamicStyle = .brandInset

        let textField = TextField(
            value: "",
            placeholder: L10n.referralAddcouponInputplaceholder,
            style: .line,
            clearButton: true
        )
        bag += form.append(
            textField.wrappedIn(
                {
                    let stackView = UIStackView()
                    stackView.isUserInteractionEnabled = true
                    stackView.isLayoutMarginsRelativeArrangement = true
                    stackView.layoutMargins = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
                    return stackView
                }()
            )
        )

        let terms = DiscountTerms()
        bag += form.append(terms)

        form.appendSpacing(.custom(24))

        let submitButton = Button(
            title: L10n.generalSaveButton,
            type: .standard(
                backgroundColor: .brand(.secondaryButtonBackgroundColor),
                textColor: .brand(.secondaryButtonTextColor)
            )
        )

        let loadableSubmitButton = LoadableButton(button: submitButton)
        bag += loadableSubmitButton.isLoadingSignal.map { !$0 }.bindTo(textField.enabledSignal)
        bag += form.append(loadableSubmitButton)

        submitButton.isEnabled.value = false
        bag += textField.value.map { $0 != "" }.bindTo(submitButton.isEnabled)

        let shouldSubmitCallbacker = Callbacker<Void>()
        bag += loadableSubmitButton.onTapSignal.onValue { _ in shouldSubmitCallbacker.callAll() }

        bag += textField.shouldReturn.set { _, textField -> Bool in textField.resignFirstResponder()
            shouldSubmitCallbacker.callAll()
            return true
        }

        bag += viewController.install(form)
        return (
            viewController,
            Future { completion in
                bag +=
                    shouldSubmitCallbacker.atValue { _ in
                        loadableSubmitButton.isLoadingSignal.value = true
                    }
                    .withLatestFrom(textField.value.plain())
                    .onValue { _, discountCode in
                        store.send(.updateRedeemedCampaigns(discountCode: discountCode))
                        
                        bag += store.stateSignal.filter(predicate: { state in !(state.offerData?.redeemedCampaigns.isEmpty ?? true) }).onValue { _ in
                            completion(.success)
                            
                            loadableSubmitButton.isLoadingSignal.value = false
                            Toasts.shared.displayToast(
                                toast: Toast(
                                    symbol: .icon(
                                        hCoreUIAssets.circularCheckmark
                                            .image
                                    ),
                                    body: L10n.Offer.discountAddedToastbar
                                )
                            )
                        }
                        
                        bag += store.onAction(.failed(event: .updateRedeemedCampaigns)) {
                            viewController.present(
                                Alert<Void>(
                                    title: L10n.Offer
                                        .discountErrorAlertTitle,
                                    message: L10n.Offer
                                        .discountErrorAlertBody,
                                    actions: [
                                        .init(
                                            title: L10n.alertOk,
                                            action: { () }
                                        )
                                    ]
                                )).onValue { _ in
                                    loadableSubmitButton.isLoadingSignal.value =
                                    false
                                }
                        }
                    }
                return bag
            }
        )
    }
}
