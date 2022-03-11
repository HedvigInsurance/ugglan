import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

public struct ApplyDiscount {
    @Inject var client: ApolloClient

    private let didRedeemValidCodeCallbacker = Callbacker<
        GraphQL.RedeemCodeMutation.Data.RedeemCodeV2.AsSuccessfulRedeemResult
    >()

    public var didRedeemValidCodeSignal: Signal<GraphQL.RedeemCodeMutation.Data.RedeemCodeV2.AsSuccessfulRedeemResult> {
        didRedeemValidCodeCallbacker.providedSignal
    }

    public init() {}
}

extension ApplyDiscount: Presentable {
    public func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        viewController.title = L10n.referralAddcouponHeadline

        let bag = DisposeBag()

        let form = FormView()
        form.dynamicStyle = .brandInset

        let descriptionLabel = MultilineLabel(
            value: L10n.referralAddcouponBody,
            style: .brand(.body(color: .secondary))
        )
        bag += form.append(descriptionLabel)

        let textField = TextField(value: "", placeholder: L10n.referralAddcouponInputplaceholder)
        bag += form.append(
            textField.wrappedIn(
                {
                    let stackView = UIStackView()
                    stackView.isUserInteractionEnabled = true
                    stackView.isLayoutMarginsRelativeArrangement = true
                    stackView.layoutMargins = UIEdgeInsets(horizontalInset: 0, verticalInset: 20)
                    return stackView
                }()
            )
        )

        let submitButton = Button(
            title: L10n.referralAddcouponBtnSubmit,
            type: .standard(
                backgroundColor: .brand(.primaryButtonBackgroundColor),
                textColor: .brand(.primaryButtonTextColor)
            )
        )

        let loadableSubmitButton = LoadableButton(button: submitButton)
        bag += loadableSubmitButton.isLoadingSignal.map { !$0 }.bindTo(textField.enabledSignal)
        bag += form.append(loadableSubmitButton)

        let terms = DiscountTerms()
        bag += form.append(terms)

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
                        func showError() {
                            let alert = Alert(
                                title: L10n.discountCodeMissing,
                                message: L10n.discountCodeMissingBody,
                                actions: [
                                    Alert.Action(
                                        title: L10n
                                            .discountCodeMissingButton
                                    ) {}
                                ]
                            )

                            viewController.present(alert)

                            loadableSubmitButton.isLoadingSignal.value = false
                        }

                        self.client
                            .perform(
                                mutation: GraphQL.RedeemCodeMutation(code: discountCode)
                            )
                            .delay(by: 0.5)
                            .onError { _ in
                                showError()
                            }
                            .onValue { data in
                                guard let successfulRedeemResult = data.redeemCodeV2.asSuccessfulRedeemResult else {
                                    showError()
                                    return
                                }

                                loadableSubmitButton.isLoadingSignal.value = false
                                self.didRedeemValidCodeCallbacker.callAll(
                                    with: successfulRedeemResult
                                )
                                completion(.success)
                            }
                    }

                return bag
            }
        )
    }
}
