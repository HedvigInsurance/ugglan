//
//  Presentable+WithCloseButton.swift
//  project
//
//  Created by Sam Pettersson on 2019-09-05.
//

import Flow
import Foundation
import Presentation
import UIKit

enum CloseButtonError: Error {
    case cancelled
}

extension Presentable where Matter: UIViewController, Result == Disposable {
    var withCloseButton: AnyPresentable<Self.Matter, Future<Void>> {
        AnyPresentable { () -> (Self.Matter, Future<Void>) in
            let (viewController, disposable) = self.materialize()

            return (viewController, Future { completion in
                let bag = DisposeBag()

                let closeButton = CloseButton()
                let closeButtonItem = UIBarButtonItem(viewable: closeButton)

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

extension Presentable where Matter: UIViewController, Result == Future<Void> {
    var withCloseButton: AnyPresentable<Self.Matter, Future<Void>> {
        AnyPresentable { () -> (Self.Matter, Self.Result) in
            let (viewController, future) = self.materialize()

            return (viewController, Future { completion in
                let bag = DisposeBag()

                let closeButton = CloseButton()
                let closeButtonItem = UIBarButtonItem(viewable: closeButton)

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
