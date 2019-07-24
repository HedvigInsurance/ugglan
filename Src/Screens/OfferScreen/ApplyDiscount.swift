
//
//  ApplyDiscount.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-06-12.
//

import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit

struct ApplyDiscount {
    let client: ApolloClient

    private let didRedeemValidCodeCallbacker = Callbacker<RedeemCodeMutation.Data.RedeemCode>()

    var didRedeemValidCodeSignal: Signal<RedeemCodeMutation.Data.RedeemCode> {
        return didRedeemValidCodeCallbacker.providedSignal
    }

    init(client: ApolloClient = ApolloContainer.shared.client) {
        self.client = client
    }
}

extension ApplyDiscount: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()

        let bag = DisposeBag()

        let containerView = UIStackView()
        bag += containerView.applySafeAreaBottomLayoutMargin()

        viewController.view = containerView

        let view = UIStackView()
        view.spacing = 5
        view.axis = .vertical
        view.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 24)
        view.isLayoutMarginsRelativeArrangement = true
        view.isUserInteractionEnabled = true

        containerView.addArrangedSubview(view)

        let titleLabel = MultilineLabel(
            value: String(key: .REFERRAL_ADDCOUPON_HEADLINE),
            style: .draggableOverlayTitle
        )
        bag += view.addArranged(titleLabel)

        let descriptionLabel = MultilineLabel(
            value: String(key: .REFERRAL_ADDCOUPON_BODY),
            style: .bodyOffBlack
        )
        bag += view.addArranged(descriptionLabel)

        let textField = TextField(value: "", placeholder: String(key: .REFERRAL_ADDCOUPON_INPUTPLACEHOLDER))
        bag += view.addArranged(textField.wrappedIn(UIStackView())) { stackView in
            stackView.isUserInteractionEnabled = true
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.layoutMargins = UIEdgeInsets(horizontalInset: 0, verticalInset: 20)
        }

        let submitButton = Button(
            title: String(key: .REFERRAL_ADDCOUPON_BTN_SUBMIT),
            type: .standard(backgroundColor: .purple, textColor: .white)
        )

        let loadableSubmitButton = LoadableButton(button: submitButton)
        bag += loadableSubmitButton.isLoadingSignal.map { !$0 }.bindTo(textField.enabledSignal)

        bag += view.addArranged(loadableSubmitButton.wrappedIn(UIStackView())) { stackView in
            stackView.axis = .vertical
            stackView.alignment = .center
        }

        let terms = DiscountTerms()
        bag += view.addArranged(terms)

        bag += view.didLayoutSignal.map { _ in
            view.systemLayoutSizeFitting(CGSize.zero)
        }.onValue { size in
            view.snp.remakeConstraints { make in
                make.height.equalTo(size.height)
            }
        }

        bag += containerView.applyPreferredContentSize(on: viewController)

        let shouldSubmitCallbacker = Callbacker<Void>()
        bag += loadableSubmitButton.onTapSignal.onValue { _ in
            shouldSubmitCallbacker.callAll()
        }

        bag += textField.shouldReturn.set { _, textField -> Bool in
            textField.resignFirstResponder()
            shouldSubmitCallbacker.callAll()
            return true
        }

        return (viewController, Future { completion in
            bag += shouldSubmitCallbacker
                .atValue { _ in
                    loadableSubmitButton.isLoadingSignal.value = true
                }
                .withLatestFrom(textField.value.plain())
                .mapLatestToFuture { _, discountCode in self.client.perform(mutation: RedeemCodeMutation(code: discountCode)) }
                .delay(by: 0.5)
                .atValue { _ in
                    loadableSubmitButton.isLoadingSignal.value = false
                }
                .onValue { result in
                    if result.errors != nil {
                        let alert = Alert(
                            title: String(key: .REFERRAL_ERROR_MISSINGCODE_HEADLINE),
                            message: String(key: .REFERRAL_ERROR_MISSINGCODE_BODY),
                            actions: [Alert.Action(title: String(key: .REFERRAL_ERROR_MISSINGCODE_BTN)) {}]
                        )

                        viewController.present(alert)
                        return
                    }

                    if let redeemCode = result.data?.redeemCode {
                        self.didRedeemValidCodeCallbacker.callAll(with: redeemCode)
                        completion(.success)
                    }
                }

            return bag
        })
    }
}
