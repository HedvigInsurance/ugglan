import Adyen
import AdyenCard
import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation

struct AdyenMethodsList {
    typealias DidSubmit = (
        _ data: PaymentComponentData,
        _ component: PaymentComponent,
        _ onResult: @escaping (_ result: Flow.Result<Either<Void, Adyen.Action>>) -> Void
    ) -> Void

    let adyenOptions: AdyenOptions
    let didSubmit: DidSubmit
}

extension AdyenMethodsList: Presentable {
    class ActionDelegate: NSObject, ActionComponentDelegate {
        typealias ResultHandler = (_ result: Flow.Result<Either<Void, Adyen.Action>>) -> Void

        @Inject var client: ApolloClient
        let onResult: ResultHandler

        init(onResult: @escaping ResultHandler) {
            self.onResult = onResult
        }

        func didProvide(_ data: ActionComponentData, from _: ActionComponent) {
            guard
                let detailsJsonData = try? JSONEncoder().encode(data.details.encodable),
                let detailsJson = String(data: detailsJsonData, encoding: .utf8) else {
                return
            }

            client.perform(
                mutation: GraphQL.AdyenAdditionalPaymentDetailsMutation(
                    req: "{\"details\": \(detailsJson), \"paymentData\": \"\(data.paymentData!)\"}"
                )
            ).onValue { data in
                if data.submitAdditionalPaymentDetails.asAdditionalPaymentsDetailsResponseFinished != nil {
                    self.onResult(.success(.make(())))
                } else if let data = data.submitAdditionalPaymentDetails.asAdditionalPaymentsDetailsResponseAction {
                    guard let jsonData = data.action.data(using: .utf8) else {
                        return
                    }
                    guard let action = try? JSONDecoder().decode(Adyen.Action.self, from: jsonData) else {
                        return
                    }

                    self.onResult(.success(.make(action)))
                } else {
                    self.onResult(.failure(AdyenError.action))
                }
            }
        }

        func didFail(with error: Error, from _: ActionComponent) {
            onResult(.failure(error))
        }
    }

    class PaymentDelegate: NSObject, PaymentComponentDelegate {
        let viewController: UIViewController
        let didSubmitHandler: DidSubmit
        let onCompletion: () -> Void
        let onRetry: () -> Void
        let bag = DisposeBag()

        init(
            viewController: UIViewController,
            didSubmitHandler: @escaping DidSubmit,
            onCompletion: @escaping () -> Void,
            onRetry: @escaping () -> Void
        ) {
            self.viewController = viewController
            self.didSubmitHandler = didSubmitHandler
            self.onCompletion = onCompletion
            self.onRetry = onRetry
        }

        func stopLoading(withSuccess success: Bool, in component: PaymentComponent) {
            if let component = component as? ApplePayComponent {
                component.stopLoading(withSuccess: success)
            } else if let component = component as? PresentableComponent {
                component.stopLoading(withSuccess: success)
            }
        }

        func handleResult(success: Bool) {
            if success {
                viewController.present(AdyenSuccess()).onValue { _ in
                    self.onCompletion()
                }
            } else {
                viewController.present(AdyenError.failed, style: .detented(.large, modally: false)).onValue { _ in
                    self.onRetry()
                }.onError { _ in
                    self.onCompletion()
                }
            }
        }

        func handleAction(_ action: Adyen.Action, from component: PaymentComponent) {
            let delegate = ActionDelegate { result in
                switch result {
                case let .success(response):
                    if response.left != nil {
                        self.stopLoading(withSuccess: true, in: component)
                        self.handleResult(success: true)
                    } else if let action = response.right {
                        self.handleAction(action, from: component)
                    }
                case .failure:
                    self.stopLoading(withSuccess: false, in: component)
                }
            }

            bag.hold(delegate)

            switch action {
            case let .redirect(redirectAction):
                let redirectComponent = RedirectComponent()
                redirectComponent.delegate = delegate
                redirectComponent.handle(redirectAction)
                bag.hold(redirectComponent)
            case let .await(awaitAction):
                let awaitComponent = AwaitComponent(style: nil)
                awaitComponent.handle(awaitAction)
                awaitComponent.delegate = delegate
                bag.hold(awaitComponent)
            case .sdk:
                fatalError("Not implemented")
            case let .threeDS2Fingerprint(fingerprintAction):
                let threeDS2Component = ThreeDS2Component()
                threeDS2Component.handle(fingerprintAction)
                bag.hold(threeDS2Component)
            case let .threeDS2Challenge(challengeAction):
                let threeDS2Component = ThreeDS2Component()
                threeDS2Component.handle(challengeAction)
                bag.hold(threeDS2Component)
            }
        }

        func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
            didSubmitHandler(data, component) { result in
                switch result {
                case let .success(response):
                    if response.left != nil {
                        self.stopLoading(withSuccess: true, in: component)
                        self.handleResult(success: true)
                    } else if let action = response.right {
                        self.handleAction(action, from: component)
                    }
                case .failure:
                    self.stopLoading(withSuccess: false, in: component)
                    self.handleResult(success: false)
                }
            }
        }

        func didFail(with error: Error, from component: PaymentComponent) {
            guard let error = error as? Adyen.ComponentError, error == .cancelled else {
                stopLoading(withSuccess: false, in: component)
                handleResult(success: false)
                return
            }

            stopLoading(withSuccess: false, in: component)
        }
    }

    func materialize() -> (UIViewController, Future<Void>) {
        let viewController = UIViewController()
        viewController.navigationItem.hidesBackButton = true

        let bag = DisposeBag()

        let form = FormView()

        let section = form.appendSection()

        bag += viewController.install(form)

        return (viewController, Future { completion in
            bag += adyenOptions.paymentMethods.regular.map { method in
                let row = RowView(title: method.displayInformation.title)

                let logoImageView = UIImageView()
                logoImageView.contentMode = .scaleAspectFit
                logoImageView.kf.setImage(with: Adyen.LogoURLProvider.logoURL(for: method, environment: .live))

                logoImageView.snp.makeConstraints { make in
                    make.width.equalTo(30)
                    make.height.equalTo(30)
                }

                row.prepend(logoImageView)
                row.append(hCoreUIAssets.chevronRight.image)

                return section.append(row).onValue {
                    guard let component = method.buildComponent(using: AdyenPaymentBuilder(encryptionPublicKey: adyenOptions.clientEncrytionKey)) else {
                        return
                    }

                    let delegate = PaymentDelegate(viewController: viewController, didSubmitHandler: didSubmit) {
                        completion(.success)
                    } onRetry: {
                        viewController.present(self.wrappedInCloseButton()).onValue {
                            completion(.success)
                        }.onError { error in
                            completion(.failure(error))
                        }
                    }
                    bag.hold(delegate)
                    bag.hold(component)

                    component.delegate = delegate

                    switch component {
                    case let component as PresentableComponent:
                        let excepted = (component.viewController is UIAlertController) || (component is ApplePayComponent)

                        if excepted {
                            viewController.present(component.viewController, animated: true)
                        } else {
                            viewController.present(component.viewController, style: .detented(.large, modally: false))
                        }
                    case let component as EmptyPaymentComponent:
                        component.initiatePayment()
                    default:
                        fatalError("Adyen payment option not implemented")
                    }
                }
            }

            return bag
        })
    }
}
