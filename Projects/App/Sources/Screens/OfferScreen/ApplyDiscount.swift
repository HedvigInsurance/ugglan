
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
import hGraphQL
import Presentation
import UIKit

struct ApplyDiscount {
    @Inject var client: ApolloClient

    private let didRedeemValidCodeCallbacker = Callbacker<GraphQL.RedeemCodeMutation.Data.RedeemCode>()

    var didRedeemValidCodeSignal: Signal<GraphQL.RedeemCodeMutation.Data.RedeemCode> {
        didRedeemValidCodeCallbacker.providedSignal
    }
}

extension ApplyDiscount: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        viewController.title = L10n.referralAddcouponHeadline

        let bag = DisposeBag()

        let form = FormView()
        form.dynamicStyle = .insetted

        let descriptionLabel = MultilineLabel(
            value: L10n.referralAddcouponBody,
            style: .brand(.body(color: .secondary))
        )
        bag += form.append(descriptionLabel)

        let textField = TextField(value: "", placeholder: L10n.referralAddcouponInputplaceholder)
        bag += form.append(textField.wrappedIn({
            let stackView = UIStackView()
            stackView.isUserInteractionEnabled = true
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.layoutMargins = UIEdgeInsets(horizontalInset: 0, verticalInset: 20)
            return stackView
        }()))

        let submitButton = Button(
            title: L10n.referralAddcouponBtnSubmit,
            type: .standard(backgroundColor: .brand(.primaryButtonBackgroundColor), textColor: .brand(.primaryButtonTextColor))
        )

        let loadableSubmitButton = LoadableButton(button: submitButton)
        bag += loadableSubmitButton.isLoadingSignal.map { !$0 }.bindTo(textField.enabledSignal)
        bag += form.append(loadableSubmitButton)

        let terms = DiscountTerms()
        bag += form.append(terms)

        let shouldSubmitCallbacker = Callbacker<Void>()
        bag += loadableSubmitButton.onTapSignal.onValue { _ in
            shouldSubmitCallbacker.callAll()
        }

        bag += textField.shouldReturn.set { _, textField -> Bool in
            textField.resignFirstResponder()
            shouldSubmitCallbacker.callAll()
            return true
        }

        bag += viewController.install(form)

        return (viewController, Future { completion in
            bag += shouldSubmitCallbacker
                .atValue { _ in
                    loadableSubmitButton.isLoadingSignal.value = true
                }
                .withLatestFrom(textField.value.plain())
                .mapLatestToFuture { _, discountCode in self.client.perform(mutation: GraphQL.RedeemCodeMutation(code: discountCode)) }
                .delay(by: 0.5)
                .atValue { _ in
                    loadableSubmitButton.isLoadingSignal.value = false
                }
                .atError { _ in
                    let alert = Alert(
                        title: L10n.referralErrorMissingcodeHeadline,
                        message: L10n.referralErrorMissingcodeBody,
                        actions: [Alert.Action(title: L10n.referralErrorMissingcodeBtn) {}]
                    )

                    viewController.present(alert)
                }
                .map { $0.redeemCode }
                .onValue { redeemCode in
                    self.didRedeemValidCodeCallbacker.callAll(with: redeemCode)
                    completion(.success)
                }

            return bag
        })
    }
}
