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

struct AdyenSetup {
    @Inject var client: ApolloClient
}

enum AdyenError: Error {
    case cancelled
}

extension AdyenSetup: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()
        let viewController = UIViewController()

        let view = UIView()
        view.backgroundColor = .primaryBackground

        viewController.view = view

        return (viewController, Future { completion in
            bag += self.client.fetch(query: AdyenAvailableMethodsQuery()).valueSignal.compactMap { $0.data?.availablePaymentMethods.paymentMethodsResponse }.onValue { paymentMethodsString in
                let configuration = DropInComponent.PaymentMethodsConfiguration()
                configuration.card.publicKey = """
                10001|BFB6886F7661789B3C3F8403659755F6F87933B132F38D8F7FE55E4E66613AB7571E05B3CEE21137D51434217820DE14833E55026C9D00D7DDE7211DF6897DE23E7F7581B938BC1FD781BC24A80A549A49D881F9415E9BE4672D192B6089679E1C128A84BC0EE0E49C67E698FF49A7DAF49CD787309C0FF86BF8C4346E55772185F957B0BD0809B77666CACB1BB8B4011E4432F2D5B584259FD39D5A30BB4843E547832151C25E72286A84756E086DED742FBDE6A36FA7DB229EA3852D30346190F700269B95864F23BC7BB139C3882E4E9A163E2486C29A6444B1AF08AD283BD7622C4B6453287D16E95DF899579634DBDA91471126BBF78DF431AD2B2142CB
                """
                configuration.card.showsStorePaymentMethodField = false

                let paymentMethods = try! JSONDecoder().decode(PaymentMethods.self, from: paymentMethodsString.data(using: .utf8)!)

                var style = DropInComponent.Style()
                style.navigation.tintColor = .primaryTintColor
                style.formComponent.header.title.font = HedvigFonts.favoritStdBook!.withSize(30)
                style.formComponent.footer.button.backgroundColor = .primaryTintColor
                style.formComponent.footer.button.title.font = HedvigFonts.favoritStdBook!.withSize(20)
                style.formComponent.footer.button.cornerRadius = 6
                style.formComponent.textField.title.font = HedvigFonts.favoritStdBook!.withSize(12)
                style.formComponent.textField.text.font = HedvigFonts.favoritStdBook!.withSize(15)
                style.formComponent.switch.title.font = HedvigFonts.favoritStdBook!.withSize(14)
                style.formComponent.backgroundColor = .primaryBackground
                style.formComponent.textField.backgroundColor = .primaryBackground
                style.formComponent.footer.backgroundColor = .primaryBackground
                style.formComponent.header.backgroundColor = .primaryBackground
                style.listComponent.backgroundColor = .primaryBackground
                style.listComponent.listItem.backgroundColor = .white
                style.navigation.backgroundColor = .primaryBackground

                let dropInComponent = DropInComponent(
                    paymentMethods: paymentMethods,
                    paymentMethodsConfiguration: configuration,
                    style: style
                )

                dropInComponent.environment = .test

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
                                paymentsRequest: "{\"paymentMethod\": \(json), \"returnUrl\": \"\(urlScheme)://\"}"
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
                            }
                        }
                    }

                    func didProvide(_ data: ActionComponentData, from component: DropInComponent) {
                        guard
                            let detailsJsonData = try? JSONSerialization.data(withJSONObject: data.details.dictionaryRepresentation),
                            let detailsJson = String(data: detailsJsonData, encoding: .utf8) else {
                            return
                        }
                        
                        self.client.perform(mutation: AdyenAdditionalPaymentDetailsMutation(req: "{\"details\": \(detailsJson), \"paymentData\": \(data.paymentData)}")).onValue { result in
                            if result.data?.submitAdditionalPaymentDetails.asAdditionalPaymentsDetailsResponseFinished != nil {
                                component.stopLoading(withSuccess: true, completion: nil)
                                self.completion(.success)
                            }
                        }
                    }

                    func didFail(with error: Error, from _: DropInComponent) {
                        self.completion(.failure(error))
                    }
                }

                let delegate = Coordinator { result in
                    completion(result)
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

                viewController.present(dropInComponent.viewController, options: [.allowSwipeDismissAlways, .unanimated]).onValue { _ in
                    completion(.success)
                }
            }

            return bag
        })
    }
}
