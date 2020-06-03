
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
import hCore
import hCoreUI
import Presentation
import UIKit

struct ApplyDiscount {
    @Inject var client: ApolloClient

    private let didRedeemValidCodeCallbacker = Callbacker<RedeemCodeMutation.Data.RedeemCode>()

    var didRedeemValidCodeSignal: Signal<RedeemCodeMutation.Data.RedeemCode> {
        return didRedeemValidCodeCallbacker.providedSignal
    }
}

extension ApplyDiscount: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()

        let bag = DisposeBag()

        let containerView = UIView()
        containerView.backgroundColor = .primaryBackground
        viewController.view = containerView

        let view = UIStackView()
        view.spacing = 5
        view.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 15)
        view.isLayoutMarginsRelativeArrangement = true
        view.axis = .vertical

        containerView.addSubview(view)

        view.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        let titleLabel = MultilineLabel(
            value: L10n.referralAddcouponHeadline,
            style: .draggableOverlayTitle
        )
        bag += view.addArranged(titleLabel)

        let descriptionLabel = MultilineLabel(
            value: L10n.referralAddcouponBody,
            style: .bodyOffBlack
        )
        bag += view.addArranged(descriptionLabel)

        let textField = TextField(value: "", placeholder: L10n.referralAddcouponInputplaceholder)
        bag += view.addArranged(textField.wrappedIn(UIStackView())) { stackView in
            stackView.isUserInteractionEnabled = true
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.layoutMargins = UIEdgeInsets(horizontalInset: 0, verticalInset: 20)
        }

        let submitButton = Button(
            title: L10n.referralAddcouponBtnSubmit,
            type: .standard(backgroundColor: .primaryButtonBackgroundColor, textColor: .primaryButtonTextColor)
        )

        let loadableSubmitButton = LoadableButton(button: submitButton)
        bag += loadableSubmitButton.isLoadingSignal.map { !$0 }.bindTo(textField.enabledSignal)

        bag += view.addArranged(loadableSubmitButton.wrappedIn(UIStackView())) { stackView in
            stackView.axis = .vertical
            stackView.alignment = .center
        }

        let terms = DiscountTerms()
        bag += view.addArranged(terms)

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
                            title: L10n.referralErrorMissingcodeHeadline,
                            message: L10n.referralErrorMissingcodeBody,
                            actions: [Alert.Action(title: L10n.referralErrorMissingcodeBtn) {}]
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
