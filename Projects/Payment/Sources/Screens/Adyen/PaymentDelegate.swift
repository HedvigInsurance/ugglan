import Adyen
import Adyen3DS2
import AdyenActions
import AdyenCard
import AdyenComponents
import Flow
import Foundation
import UIKit

class AdyenPresentationDelegate: NSObject, PresentationDelegate {
    let viewController: UIViewController
    var presentedViewControllers: [UIViewController] = []

    init(
        viewController: UIViewController
    ) {
        self.viewController = viewController
    }

    func dismissAll() {
        presentedViewControllers.forEach { viewController in
            viewController.dismiss(animated: true, completion: nil)
        }
    }

    func present(component: PresentableComponent) {
        viewController.present(component.viewController, animated: true)
        presentedViewControllers.append(component.viewController)
    }
}

class PaymentDelegate: NSObject, PaymentComponentDelegate {
    let viewController: UIViewController
    let paymentMethod: PaymentMethod
    let didSubmitHandler: AdyenMethodsList.DidSubmit
    let onCompletion: () -> Void
    let onEnd: () -> Void
    let onRetry: () -> Void
    let onSuccess: () -> Void
    let bag = DisposeBag()

    var presentationDelegates: [AdyenPresentationDelegate] = []

    init(
        viewController: UIViewController,
        paymentMethod: PaymentMethod,
        didSubmitHandler: @escaping AdyenMethodsList.DidSubmit,
        onCompletion: @escaping () -> Void,
        onEnd: @escaping () -> Void,
        onRetry: @escaping () -> Void,
        onSuccess: @escaping () -> Void
    ) {
        self.viewController = viewController
        self.paymentMethod = paymentMethod
        self.didSubmitHandler = didSubmitHandler
        self.onEnd = onEnd
        self.onCompletion = onCompletion
        self.onRetry = onRetry
        self.onSuccess = onSuccess
    }

    func stopLoading(withSuccess success: Bool, in component: PaymentComponent) {
        component.stopLoadingIfNeeded()
        component.finalizeIfNeeded(with: success)

        self.presentationDelegates.forEach { presentationDelegate in
            presentationDelegate.dismissAll()
        }

        if let component = component as? PresentableComponent {
            component.viewController.dismiss(animated: true, completion: nil)
        }
    }

    func handleResult(success: Bool) {
        if success {
            onSuccess()

            bag +=
                viewController.present(
                    AdyenSuccess(paymentMethod: paymentMethod),
                    style: .detented(.large, modally: false),
                    options: [.defaults, .autoPop]
                )
                .atEnd {
                    self.onEnd()
                }
                .onValue { _ in self.onCompletion() }
        } else {
            bag +=
                viewController.present(
                    AdyenError.failed,
                    style: .detented(.large, modally: false),
                    options: [.defaults, .autoPop]
                )
                .atEnd { self.onEnd() }
                .onValue { _ in self.onRetry() }
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

        let presentationDelegate: AdyenPresentationDelegate

        if let component = component as? PresentableComponent {
            presentationDelegate = AdyenPresentationDelegate(viewController: component.viewController)
        } else {
            presentationDelegate = AdyenPresentationDelegate(viewController: viewController)
        }

        presentationDelegates.append(presentationDelegate)

        switch action {
        case let .redirect(redirectAction):
            let redirectComponent = RedirectComponent(apiContext: HedvigAdyenAPIContext().apiContext)
            redirectComponent.delegate = delegate
            redirectComponent.presentationDelegate = presentationDelegate
            redirectComponent.handle(redirectAction)
            bag.hold(redirectComponent)
        case let .await(awaitAction):
            let awaitComponent = AwaitComponent(apiContext: HedvigAdyenAPIContext().apiContext, style: nil)
            awaitComponent.delegate = delegate
            awaitComponent.presentationDelegate = presentationDelegate
            awaitComponent.handle(awaitAction)
            bag.hold(awaitComponent)
        case .sdk: fatalError("Not implemented")
        case let .threeDS2Fingerprint(fingerprintAction):
            threeDS2Component.delegate = delegate
            threeDS2Component.presentationDelegate = presentationDelegate
            threeDS2Component.handle(fingerprintAction)
        case let .threeDS2Challenge(challengeAction):
            threeDS2Component.delegate = delegate
            threeDS2Component.presentationDelegate = presentationDelegate
            threeDS2Component.handle(challengeAction)
        case let .threeDS2(action):
            threeDS2Component.delegate = delegate
            threeDS2Component.presentationDelegate = presentationDelegate
            threeDS2Component.handle(action)
        case .voucher(_): break
        case .qrCode(_): break
        case .document: break
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
