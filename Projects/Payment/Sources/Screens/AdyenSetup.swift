import Adyen
import AdyenDropIn
import Apollo
import Flow
import Foundation
import hCore
import hCoreUI
import hGraphQL
import PassKit
import Presentation
import UIKit

struct AdyenSetup {
    @Inject var client: ApolloClient
    @Inject var store: ApolloStore
    let urlScheme: String
}

enum AdyenError: Error {
    case cancelled, tokenization, action
}

extension AdyenSetup: Presentable {
    public func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        viewController.navigationItem.hidesBackButton = true

        let view = UIView()
        view.backgroundColor = .brand(.primaryBackground())

        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .whiteLarge
        activityIndicator.color = .brand(.primaryTintColor)

        view.addSubview(activityIndicator)

        activityIndicator.startAnimating()

        activityIndicator.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalToSuperview()
        }

        viewController.view = view

        return (viewController, Future { completion in
            bag += self.client.fetch(query: GraphQL.AdyenAvailableMethodsQuery()).onValue { data in
                let configuration = DropInComponent.PaymentMethodsConfiguration()
                configuration.card.publicKey = data.adyenPublicKey
                configuration.card.showsStorePaymentMethodField = false
                configuration.localizationParameters = LocalizationParameters(tableName: "Adyen", keySeparator: ".")
                configuration.applePay.summaryItems = [
                    PKPaymentSummaryItem(label: "Hedvig", amount: NSDecimalNumber(string: "0"), type: .pending),
                ]

                let paymentMethods = try! JSONDecoder().decode(PaymentMethods.self, from: data.availablePaymentMethods.paymentMethodsResponse.data(using: .utf8)!)

                var style = DropInComponent.Style()
                style.navigation.tintColor = .brand(.primaryTintColor)
                style.formComponent.header.title.font = Fonts.fontFor(style: .title1)
                style.formComponent.footer.button.backgroundColor = .brand(.primaryButtonBackgroundColor)
                style.formComponent.footer.button.title.font = Fonts.fontFor(style: .title3)
                style.formComponent.footer.button.cornerRadius = 6
                style.formComponent.textField.title.font = Fonts.fontFor(style: .caption1)
                style.formComponent.textField.text.font = Fonts.fontFor(style: .body)
                style.formComponent.switch.title.font = Fonts.fontFor(style: .footnote)
                style.formComponent.backgroundColor = .brand(.primaryBackground())
                style.formComponent.textField.backgroundColor = .brand(.primaryBackground())
                style.formComponent.footer.backgroundColor = .brand(.primaryBackground())
                style.formComponent.header.backgroundColor = .brand(.primaryBackground())
                style.listComponent.backgroundColor = .brand(.primaryBackground())
                style.listComponent.listItem.backgroundColor = .brand(.secondaryBackground())
                style.navigation.backgroundColor = .brand(.primaryBackground())

                switch ApplicationState.getTargetEnvironment() {
                case .staging:
                    configuration.applePay.merchantIdentifier = "merchant.com.hedvig.test.app"
                case .production:
                    configuration.applePay.merchantIdentifier = "merchant.com.hedvig.app"
                case .custom:
                    configuration.applePay.merchantIdentifier = "merchant.com.hedvig.test.app"
                }

                let dropInComponent = DropInComponent(
                    paymentMethods: paymentMethods,
                    paymentMethodsConfiguration: configuration,
                    style: style
                )

                let payment = Payment(amount: Payment.Amount(value: 0, currencyCode: data.insuranceCost?.fragments.costFragment.monthlyNet.currency ?? ""), countryCode: Localization.Locale.currentLocale.market.rawValue)

                dropInComponent.payment = payment

                switch ApplicationState.getTargetEnvironment() {
                case .staging:
                    dropInComponent.environment = .test
                case .production:
                    dropInComponent.environment = .live
                case .custom:
                    dropInComponent.environment = .test
                }

                class Coordinator: NSObject, DropInComponentDelegate {
                    @Inject var client: ApolloClient
                    let urlScheme: String
                    let completion: (_ result: Flow.Result<Void>) -> Void

                    init(
                        urlScheme: String,
                        _ completion: @escaping (_ result: Flow.Result<Void>) -> Void
                    ) {
                        self.urlScheme = urlScheme
                        self.completion = completion
                    }

                    func didSubmit(_ data: PaymentComponentData, from component: DropInComponent) {
                        guard
                            let jsonData = try? JSONSerialization.data(withJSONObject: data.paymentMethod.dictionaryRepresentation),
                            let json = String(data: jsonData, encoding: .utf8) else {
                            return
                        }

                        self.client.perform(
                            mutation: GraphQL.AdyenTokenizePaymentDetailsMutation(
                                request: GraphQL.TokenizationRequest(paymentMethodDetails: json.replacingOccurrences(of: "applepay.token", with: "applepayToken"), channel: .ios, returnUrl: "\(self.urlScheme)://adyen")
                            )
                        ).onValue { data in
                            if data.tokenizePaymentDetails?.asTokenizationResponseFinished != nil {
                                component.stopLoading(withSuccess: true, completion: nil)
                                self.completion(.success)
                            } else if let data = data.tokenizePaymentDetails?.asTokenizationResponseAction {
                                guard let jsonData = data.action.data(using: .utf8) else {
                                    return
                                }
                                guard let action = try? JSONDecoder().decode(Adyen.Action.self, from: jsonData) else {
                                    return
                                }

                                component.handle(action)
                            } else {
                                component.stopLoading(withSuccess: false, completion: nil)
                                component.delegate?.didFail(with: AdyenError.tokenization, from: component)
                            }
                        }
                    }

                    func didProvide(_ data: ActionComponentData, from component: DropInComponent) {
                        guard
                            let detailsJsonData = try? JSONSerialization.data(withJSONObject: data.details.dictionaryRepresentation),
                            let detailsJson = String(data: detailsJsonData, encoding: .utf8) else {
                            return
                        }

                        self.client.perform(mutation: GraphQL.AdyenAdditionalPaymentDetailsMutation(req: "{\"details\": \(detailsJson), \"paymentData\": \"\(data.paymentData)\"}")).onValue { data in
                            if data.submitAdditionalPaymentDetails.asAdditionalPaymentsDetailsResponseFinished != nil {
                                component.stopLoading(withSuccess: true, completion: nil)
                                self.completion(.success)
                            } else if let data = data.submitAdditionalPaymentDetails.asAdditionalPaymentsDetailsResponseAction {
                                guard let jsonData = data.action.data(using: .utf8) else {
                                    return
                                }
                                guard let action = try? JSONDecoder().decode(Adyen.Action.self, from: jsonData) else {
                                    return
                                }

                                component.handle(action)
                            } else {
                                component.stopLoading(withSuccess: false, completion: nil)
                                component.delegate?.didFail(with: AdyenError.action, from: component)
                            }
                        }
                    }

                    func didFail(with error: Error, from _: DropInComponent) {
                        self.completion(.failure(error))
                    }
                }

                let delegate = Coordinator(urlScheme: self.urlScheme) { result in
                    switch result {
                    case .success:
                        self.client.fetch(
                            query: GraphQL.ActivePaymentMethodsQuery(),
                            cachePolicy: .fetchIgnoringCacheData
                        ).onValue { _ in }

                        let continueButton = Button(
                            title: L10n.paymentSetupDoneCta,
                            type: .standard(backgroundColor: .brand(.primaryButtonBackgroundColor), textColor: .brand(.primaryButtonTextColor))
                        )

                        // TODO: Correct icon
                        let continueAction = ImageTextAction<Void>(
                            image: .init(image: hCoreUIAssets.addButton.image, size: CGSize(width: 64, height: 64), contentMode: .scaleAspectFit),
                            title: L10n.paymentSetupDoneTitle,
                            body: L10n.paymentSetupDoneDescription,
                            actions: [
                                ((), continueButton),
                            ],
                            showLogo: false
                        )

                        bag += dropInComponent.viewController.present(PresentableViewable(viewable: continueAction) { viewController in
                            viewController.navigationItem.hidesBackButton = true
                        }).onValue { _ in
                            completion(.success)
                        }
                    case .failure:
                        let tryAgainButton = Button(
                            title: L10n.paymentSetupFailedRetryCta,
                            type: .standard(backgroundColor: .brand(.primaryButtonBackgroundColor), textColor: .brand(.primaryButtonTextColor))
                        )

                        let cancelButton = Button(
                            title: L10n.paymentSetupFailedCancelCta,
                            type: .outline(borderColor: .clear, textColor: .brand(.link))
                        )

                        // TODO: correct icon
                        let didFailAction = ImageTextAction<Bool>(
                            image: .init(image: hCoreUIAssets.addButton.image, size: CGSize(width: 64, height: 64), contentMode: .scaleAspectFit),
                            title: L10n.paymentSetupFailedTitle,
                            body: L10n.paymentSetupFailedDescription,
                            actions: [
                                (true, tryAgainButton),
                                (false, cancelButton),
                            ],
                            showLogo: false
                        )

                        bag += dropInComponent.viewController.present(PresentableViewable(viewable: didFailAction) { viewController in
                            viewController.navigationItem.hidesBackButton = true
                        }).onValue { shouldRetry in
                            if shouldRetry {
                                dropInComponent.viewController.present(AdyenSetup(urlScheme: urlScheme)).onResult { result in
                                    completion(result)
                                }
                            } else {
                                completion(.failure(AdyenError.cancelled))
                            }
                        }
                    }
                }
                bag.hold(delegate)
                bag.hold(dropInComponent)

                dropInComponent.delegate = delegate

                dropInComponent.viewController.navigationItem.hidesBackButton = true
                if #available(iOS 13.0, *) {
                    dropInComponent.viewController.isModalInPresentation = false
                }

                let closeButton = CloseButton()

                bag += closeButton.onTapSignal.onValue { _ in
                    completion(.failure(AdyenError.cancelled))
                }

                let closeButtonItem = UIBarButtonItem(viewable: closeButton)

                dropInComponent.viewController.navigationItem.rightBarButtonItem = closeButtonItem

                viewController.present(dropInComponent.viewController, options: [
                    .allowSwipeDismissAlways,
                ]).onValue { _ in
                    completion(.success)
                }
            }

            return DelayedDisposer(bag, delay: 2)
        }.onValue { _ in
            self.store.update(query: GraphQL.PayInMethodStatusQuery()) { (data: inout GraphQL.PayInMethodStatusQuery.Data) in
                data.payinMethodStatus = .active
            }
        })
    }
}
