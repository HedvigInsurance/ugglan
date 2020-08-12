//
//  Presentable+WithCloseButton.swift
//  project
//
//  Created by Sam Pettersson on 2019-09-05.
//

import Flow
import Foundation
import hCore
import Presentation
import UIKit

enum CloseButtonError: Error {
    case cancelled
}

extension PresentationStyle {
    public static let modallyWithCloseButton = PresentationStyle(name: "ModallyWithCloseButton") { (viewController, from, options) -> PresentationStyle.Result in
        let bag = DisposeBag()
        let closeButton = CloseButton()
        let closeButtonItem = UIBarButtonItem(viewable: closeButton)

        viewController.navigationItem.rightBarButtonItem = closeButtonItem

        let result = PresentationStyle.modally(
            presentationStyle: .formSheet,
            transitionStyle: nil,
            capturesStatusBarAppearance: true
        ).present(viewController, from: from, options: options)

        bag += closeButton.onTapSignal.onValue { _ in
            bag.dispose()
            result.dismisser().onValue { _ in }
        }

        return result
    }
}

extension Presentable where Matter: UIViewController, Result == Disposable {
    public var withCloseButton: AnyPresentable<Self.Matter, Future<Void>> {
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
    public var withCloseButton: AnyPresentable<Self.Matter, Future<Void>> {
        AnyPresentable { () -> (Self.Matter, Self.Result) in
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
