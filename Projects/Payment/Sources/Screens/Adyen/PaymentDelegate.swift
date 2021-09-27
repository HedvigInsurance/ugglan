import Adyen
import Adyen3DS2
import AdyenActions
import AdyenCard
import AdyenComponents
import Flow
import Foundation
import UIKit

class PaymentDelegate: NSObject, PaymentComponentDelegate {
    let viewController: UIViewController
    let paymentMethod: PaymentMethod
    let didSubmitHandler: AdyenMethodsList.DidSubmit
    let onCompletion: () -> Void
    let onRetry: () -> Void
    let onSuccess: () -> Void
    let bag = DisposeBag()

    init(
        viewController: UIViewController,
        paymentMethod: PaymentMethod,
        didSubmitHandler: @escaping AdyenMethodsList.DidSubmit,
        onCompletion: @escaping () -> Void,
        onRetry: @escaping () -> Void,
        onSuccess: @escaping () -> Void
    ) {
        self.viewController = viewController
        self.paymentMethod = paymentMethod
        self.didSubmitHandler = didSubmitHandler
        self.onCompletion = onCompletion
        self.onRetry = onRetry
        self.onSuccess = onSuccess
    }

    func stopLoading(withSuccess success: Bool, in component: PaymentComponent) {
        if let component = component as? ApplePayComponent {
            component.stopLoadingIfNeeded()
        } else if let component = component as? PresentableComponent {
            component.stopLoadingIfNeeded()
        }
    }

    func handleResult(success: Bool) {
        if success {
            onSuccess()

            viewController.present(
                AdyenSuccess(paymentMethod: paymentMethod),
                style: .detented(.large, modally: false)
            )
            .onValue { _ in self.onCompletion() }
        } else {
            viewController.present(AdyenError.failed, style: .detented(.large, modally: false))
                .onValue { _ in self.onRetry() }.onError { _ in self.onCompletion() }
        }
    }

    lazy var threeDS2Component: ThreeDS2Component = {
        let threeDS2Component = ThreeDS2Component(apiContext: HedvigAdyenAPIContext().apiContext)
        bag.hold(threeDS2Component)
        return threeDS2Component
    }()

    func handleAction(_ action: AdyenActions.Action, from component: PaymentComponent) {
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
                self.handleResult(success: false)
            }
        }

        bag.hold(delegate)

        switch action {
        case let .redirect(redirectAction):
            let redirectComponent = RedirectComponent(apiContext: HedvigAdyenAPIContext().apiContext)
            redirectComponent.delegate = delegate
            redirectComponent.handle(redirectAction)
            bag.hold(redirectComponent)
        case let .await(awaitAction):
            let awaitComponent = AwaitComponent(apiContext: HedvigAdyenAPIContext().apiContext, style: nil)
            awaitComponent.delegate = delegate
            awaitComponent.handle(awaitAction)
            bag.hold(awaitComponent)
        case .sdk: fatalError("Not implemented")
        case let .threeDS2Fingerprint(fingerprintAction):
            threeDS2Component.delegate = delegate
            threeDS2Component.handle(fingerprintAction)
        case let .threeDS2Challenge(challengeAction):
            threeDS2Component.delegate = delegate
            threeDS2Component.handle(challengeAction)
        case .threeDS2(_): #warning("should we handle this")
        case .voucher(_): break
        case .qrCode(_): break
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
