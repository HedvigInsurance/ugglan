import Flow
import Foundation
import hCore
import Presentation
import UIKit

enum CloseButtonError: Error {
    case cancelled
}

public extension Presentable where Matter: UIViewController, Result == Disposable {
    var withCloseButton: AnyPresentable<Self.Matter, Future<Void>> {
        AnyPresentable { () -> (Self.Matter, Future<Void>) in
            let (viewController, disposable) = self.materialize()

            if let presentableIdentifier = (self as? PresentableIdentifierExpressible)?.presentableIdentifier {
                viewController.debugPresentationTitle = presentableIdentifier.value
            } else {
                let title = "\(type(of: self))"
                if !title.hasPrefix("AnyPresentable<") {
                    viewController.debugPresentationTitle = title
                }
            }

            return (viewController, Future { completion in
                let bag = DisposeBag()

                let closeButton = CloseButton()
                let closeButtonItem = UIBarButtonItem(viewable: closeButton)

                // move over any barButtonItems to the other side
                if viewController.navigationItem.rightBarButtonItems != nil {
                    viewController.navigationItem.leftBarButtonItems = viewController.navigationItem.rightBarButtonItems
                }

                viewController.navigationItem.rightBarButtonItem = closeButtonItem

                bag += closeButton.onTapSignal.onValue { _ in
                    completion(.failure(CloseButtonError.cancelled))
                }

                bag += disposable

                return DelayedDisposer(bag, delay: 2)
            })
        }
    }
}

public extension Presentable where Matter: UIViewController {
    func wrappedInCloseButton<T>() -> AnyPresentable<Self.Matter, Future<T>> where Self.Result == Future<T> {
        AnyPresentable { () -> (Self.Matter, Future<T>) in
            let (viewController, future) = self.materialize()

            if let presentableIdentifier = (self as? PresentableIdentifierExpressible)?.presentableIdentifier {
                viewController.debugPresentationTitle = presentableIdentifier.value
            } else {
                let title = "\(type(of: self))"
                if !title.hasPrefix("AnyPresentable<") {
                    viewController.debugPresentationTitle = title
                }
            }

            return (viewController, Future { completion in
                let bag = DisposeBag()

                let closeButton = CloseButton()
                let closeButtonItem = UIBarButtonItem(viewable: closeButton)

                // move over any barButtonItems to the other side
                if viewController.navigationItem.rightBarButtonItems != nil {
                    viewController.navigationItem.leftBarButtonItems = viewController.navigationItem.rightBarButtonItems
                }

                viewController.navigationItem.rightBarButtonItem = closeButtonItem

                bag += closeButton.onTapSignal.onValue { _ in
                    completion(.failure(CloseButtonError.cancelled))
                }

                bag += future.onResult(completion)

                bag += {
                    future.cancel()
                }

                return DelayedDisposer(bag, delay: 2)
            })
        }
    }
}
