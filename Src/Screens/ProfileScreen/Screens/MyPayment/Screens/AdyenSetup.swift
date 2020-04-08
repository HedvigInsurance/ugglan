//
//  AdyenSetup.swift
//  test
//
//  Created by sam on 24.3.20.
//

import Adyen
import AdyenDropIn
import Apollo
import Flow
import Foundation
import Presentation
import UIKit
import PassKit

struct AdyenSetup {
    @Inject var client: ApolloClient
    @Inject var store: ApolloStore
}

enum AdyenError: Error {
    case cancelled, tokenization, action
}

extension AdyenSetup: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()
        let viewController = UIViewController()
        viewController.navigationItem.hidesBackButton = true

        let view = UIView()
        view.backgroundColor = .primaryBackground
        
        let activityIndicator = UIActivityIndicatorView()
       activityIndicator.style = .whiteLarge
       activityIndicator.color = .primaryTintColor

       view.addSubview(activityIndicator)

       activityIndicator.startAnimating()

       activityIndicator.snp.makeConstraints { make in
           make.edges.equalToSuperview()
           make.size.equalToSuperview()
       }

        viewController.view = view

        return (viewController, Future { completion in
            bag += self.client.fetch(query: AdyenAvailableMethodsQuery()).valueSignal.compactMap { $0.data }.onValue { data in
                let configuration = DropInComponent.PaymentMethodsConfiguration()
                configuration.card.publicKey = data.adyenPublicKey
                configuration.card.showsStorePaymentMethodField = false
                configuration.localizationParameters = LocalizationParameters(tableName: "Adyen", keySeparator: ".")
                configuration.applePay.summaryItems = [
                    PKPaymentSummaryItem(label: "Hedvig", amount: NSDecimalNumber(string: "0"), type: .pending),
                ]
                
                let paymentMethods = try! JSONDecoder().decode(PaymentMethods.self, from: data.availablePaymentMethods.paymentMethodsResponse.data(using: .utf8)!)
                
                var style = DropInComponent.Style()
                style.navigation.tintColor = .primaryTintColor
                style.formComponent.header.title.font = HedvigFonts.favoritStdBook!.withSize(30)
                style.formComponent.footer.button.backgroundColor = .primaryButtonBackgroundColor
                style.formComponent.footer.button.title.font = HedvigFonts.favoritStdBook!.withSize(20)
                style.formComponent.footer.button.title.color = .primaryButtonTextColor
                style.formComponent.footer.button.cornerRadius = 6
                style.formComponent.textField.title.font = HedvigFonts.favoritStdBook!.withSize(12)
                style.formComponent.textField.text.font = HedvigFonts.favoritStdBook!.withSize(15)
                style.formComponent.switch.title.font = HedvigFonts.favoritStdBook!.withSize(14)
                style.formComponent.backgroundColor = .primaryBackground
                style.formComponent.textField.backgroundColor = .primaryBackground
                style.formComponent.footer.backgroundColor = .primaryBackground
                style.formComponent.header.backgroundColor = .primaryBackground
                style.listComponent.backgroundColor = .primaryBackground
                style.listComponent.listItem.backgroundColor = .secondaryBackground
                style.navigation.backgroundColor = .primaryBackground
                
                switch ApplicationState.getTargetEnvironment() {
                case .staging:
                    configuration.applePay.merchantIdentifier = "merchant.com.hedvig.test.app"
                case .production:
                    configuration.applePay.merchantIdentifier = "merchant.com.hedvig.app"
                case .custom(_, _, _):
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
                case .custom(_, _, _):
                    dropInComponent.environment = .test
                }

                class Coordinator: NSObject, DropInComponentDelegate {
                    @Inject var client: ApolloClient
                    let completion: (_ result: Flow.Result<Void>) -> Void

                    init(_ completion: @escaping (_ result: Flow.Result<Void>) -> Void) {
                        self.completion = completion
                    }

                    func didSubmit(_ data: PaymentComponentData, from component: DropInComponent) {
                        guard
                            let jsonData = try? JSONSerialization.data(withJSONObject: data.paymentMethod.dictionaryRepresentation),
                            let json = String(data: jsonData, encoding: .utf8) else {
                            return
                        }
                                                
                        let urlScheme = Bundle.main.urlScheme ?? ""
                        
                        self.client.perform(
                            mutation: AdyenTokenizePaymentDetailsMutation(
                                request: TokenizationRequest(paymentMethodDetails: json.replacingOccurrences(of: "applepay.token", with: "applepayToken"), channel: .ios, returnUrl: "\(urlScheme)://adyen")
                            )
                        ).onValue { result in
                            if result.data?.tokenizePaymentDetails?.asTokenizationResponseFinished != nil {
                                component.stopLoading(withSuccess: true, completion: nil)
                                self.completion(.success)
                            } else if let data = result.data?.tokenizePaymentDetails?.asTokenizationResponseAction {
                                guard let jsonData = data.action.data(using: .utf8) else {
                                    return
                                }
                                guard let action = try? JSONDecoder().decode(Action.self, from: jsonData) else {
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

                        self.client.perform(mutation: AdyenAdditionalPaymentDetailsMutation(req: "{\"details\": \(detailsJson), \"paymentData\": \"\(data.paymentData)\"}")).onValue { result in
                            if result.data?.submitAdditionalPaymentDetails.asAdditionalPaymentsDetailsResponseFinished != nil {
                                component.stopLoading(withSuccess: true, completion: nil)
                                self.completion(.success)
                            } else if let data = result.data?.submitAdditionalPaymentDetails.asAdditionalPaymentsDetailsResponseAction {
                                guard let jsonData = data.action.data(using: .utf8) else {
                                    return
                                }
                                guard let action = try? JSONDecoder().decode(Action.self, from: jsonData) else {
                                    return
                                }

                                component.handle(action)
                            } else {
                                component.stopLoading(withSuccess: false, completion: nil)
                                component.delegate?.didFail(with: AdyenError.action, from: component)
                            }
                        }
                    }

                    func didFail(with error: Error, from dropInComponent: DropInComponent) {
                        self.completion(.failure(error))
                    }
                }

                let delegate = Coordinator { result in
                    switch result {
                    case .success:
                        self.client.fetch(
                            query: ActivePaymentMethodsQuery(),
                            cachePolicy: .fetchIgnoringCacheData
                        ).onValue { _ in }
                        
                        let continueButton = Button(
                            title: String(key: .PAYMENT_SETUP_DONE_CTA),
                            type: .standard(backgroundColor: .primaryButtonBackgroundColor, textColor: .primaryButtonTextColor)
                      )

                      let continueAction = ImageTextAction<Void>(
                        image: .init(image: Asset.circularCheckmark.image, size: CGSize(width: 64, height: 64), contentMode: .scaleAspectFit),
                            title: String(key: .PAYMENT_SETUP_DONE_TITLE),
                            body:  String(key: .PAYMENT_SETUP_DONE_DESCRIPTION),
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
                            title: String(key: .PAYMENT_SETUP_FAILED_RETRY_CTA),
                          type: .standard(backgroundColor: .primaryButtonBackgroundColor, textColor: .primaryButtonTextColor)
                      )
                        
                        let cancelButton = Button(
                              title: String(key: .PAYMENT_SETUP_FAILED_CANCEL_CTA),
                            type: .outline(borderColor: .transparent, textColor: .pink)
                        )

                          let didFailAction = ImageTextAction<Bool>(
                            image: .init(image: Asset.redCross.image, size: CGSize(width: 64, height: 64), contentMode: .scaleAspectFit),
                                title: String(key: .PAYMENT_SETUP_FAILED_TITLE),
                                body:  String(key: .PAYMENT_SETUP_FAILED_DESCRIPTION),
                              actions: [
                                  (true, tryAgainButton),
                                  (false, cancelButton)
                              ],
                              showLogo: false
                          )

                        bag += dropInComponent.viewController.present(PresentableViewable(viewable: didFailAction) { viewController in
                            viewController.navigationItem.hidesBackButton = true
                        }).onValue { shouldRetry in
                            if (shouldRetry) {
                                dropInComponent.viewController.present(AdyenSetup()).onResult { result in
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
            self.store.update(query: MyPaymentQuery(), updater: { (data: inout MyPaymentQuery.Data) in
                data.payinMethodStatus = .active
            })

            AnalyticsCoordinator().logAddPaymentInfo()
        })
    }
}
