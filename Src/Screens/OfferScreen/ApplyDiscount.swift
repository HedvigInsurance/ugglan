
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

        let containerView = UIStackView()
        bag += containerView.applySafeAreaBottomLayoutMargin()
        
        let view = UIView()
        viewController.view.addSubview(view)
        view.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }

        let stackView = UIStackView()
        stackView.spacing = 5
        stackView.axis = .vertical
        stackView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 24)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.isUserInteractionEnabled = true

        containerView.addArrangedSubview(stackView)

        let titleLabel = MultilineLabel(
            value: String(key: .REFERRAL_ADDCOUPON_HEADLINE),
            style: .draggableOverlayTitle
        )
        bag += stackView.addArranged(titleLabel)

        let descriptionLabel = MultilineLabel(
            value: String(key: .REFERRAL_ADDCOUPON_BODY),
            style: .bodyOffBlack
        )
        bag += stackView.addArranged(descriptionLabel)

        let textField = TextField(value: "", placeholder: String(key: .REFERRAL_ADDCOUPON_INPUTPLACEHOLDER))
        bag += stackView.addArranged(textField.wrappedIn(UIStackView())) { stackView in
            stackView.isUserInteractionEnabled = true
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.layoutMargins = UIEdgeInsets(horizontalInset: 0, verticalInset: 20)
        }

        let submitButton = Button(
            title: String(key: .REFERRAL_ADDCOUPON_BTN_SUBMIT),
            type: .standard(backgroundColor: .primaryTintColor, textColor: .white)
        )

        let loadableSubmitButton = LoadableButton(button: submitButton)
        bag += loadableSubmitButton.isLoadingSignal.map { !$0 }.bindTo(textField.enabledSignal)

        bag += stackView.addArranged(loadableSubmitButton.wrappedIn(UIStackView())) { stackView in
            stackView.axis = .vertical
            stackView.alignment = .center
        }

        let terms = DiscountTerms()
        bag += stackView.addArranged(terms)

        bag += stackView.didLayoutSignal.map { _ in
            stackView.systemLayoutSizeFitting(CGSize.zero)
        }.onValue { size in
            stackView.snp.remakeConstraints { make in
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
