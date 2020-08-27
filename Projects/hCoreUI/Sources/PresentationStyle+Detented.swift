//
//  PresentationStyle+Detented.swift
//  hCore
//
//  Created by sam on 24.8.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import Presentation
import UIKit

func setGrabber(on presentationController: UIPresentationController, to value: Bool) {
    let grabberKey = [
        "_", "setWants", "Grabber:",
    ]

    let selector = NSSelectorFromString(grabberKey.joined())

    if presentationController.responds(to: selector) {
        if value {
            presentationController.perform(selector, with: value)
        } else {
            presentationController.perform(selector, with: nil)
        }
    }
}

func getDetentIndex(on presentationController: UIPresentationController) -> Int {
    let key = [
        "_", "indexOf", "CurrentDetent",
    ]

    return presentationController.value(forKey: key.joined()) as? Int ?? 0
}

func setDetentIndex(on presentationController: UIPresentationController, index: Int) {
    let key = [
        "_set", "IndexOf", "CurrentDetent:",
    ]
            
    typealias SetIndexMethod = @convention(c) (
        UIPresentationController,
        Selector,
        Int
    ) -> Void
    let selector = NSSelectorFromString(key.joined())
    let method = presentationController.method(for: selector)
    let castedMethod = unsafeBitCast(method, to: SetIndexMethod.self)

    castedMethod(presentationController, selector, index)
}

class DetentedTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var detents: [PresentationStyle.Detent]
    var wantsGrabber: Bool
    var viewController: UIViewController

    init(
        detents: [PresentationStyle.Detent],
        wantsGrabber: Bool,
        viewController: UIViewController
    ) {
        self.detents = detents
        self.wantsGrabber = wantsGrabber
        self.viewController = viewController
        super.init()
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source _: UIViewController) -> UIPresentationController? {
        let key = [
            "_", "U", "I", "Sheet", "Presentation", "Controller",
        ]
        let sheetPresentationController = NSClassFromString(key.joined()) as! UIPresentationController.Type
        let presentationController = sheetPresentationController.init(presentedViewController: presented, presenting: presenting)

        PresentationStyle.Detent.set(detents, on: presentationController, viewController: viewController)
        setGrabber(on: presentationController, to: wantsGrabber)

        return presentationController
    }
}

extension PresentationOptions {
    // adds a grabber to DetentedModals
    public static let wantsGrabber = PresentationOptions()
}

extension UIViewController {
    private static var _appliedDetents: UInt8 = 1

    var appliedDetents: [PresentationStyle.Detent] {
        get {
            if let appliedDetents = objc_getAssociatedObject(
                self,
                &UIViewController._appliedDetents
            ) as? [PresentationStyle.Detent] {
                return appliedDetents
            }

            return []
        }
        set {
            objc_setAssociatedObject(
                self,
                &UIViewController._appliedDetents,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    private static var _lastDetentIndex: UInt8 = 1
    
    var lastDetentIndex: Int? {
        get {
            if let lastDetentIndex = objc_getAssociatedObject(
                self,
                &UIViewController._lastDetentIndex
            ) as? Int {
                return lastDetentIndex
            }

            return nil
        }
        set {
            objc_setAssociatedObject(
                self,
                &UIViewController._lastDetentIndex,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}

extension PresentationStyle {
    public enum Detent {
        case medium, large, custom(_ containerViewBlock: (_ viewController: UIViewController, _ containerView: UIView) -> CGFloat)

        public static func scrollViewContentSize(_ extraPadding: CGFloat = 0) -> Detent {
            .custom { viewController, containerView in
                guard let scrollView = viewController.view as? UIScrollView else {
                    return 0
                }

                return scrollView.contentSize.height + containerView.safeAreaInsets.bottom + extraPadding
            }
        }

        public static var preferredContentSize: Detent {
            .custom { viewController, _ in
                viewController.preferredContentSize.height
            }
        }

        static func set(_ detents: [Detent], on presentationController: UIPresentationController, viewController: UIViewController, lastDetentIndex: Int? = nil) {
            let key = [
                "_", "set", "Detents", ":",
            ]
            let selector = NSSelectorFromString(key.joined())
            viewController.appliedDetents = detents
            presentationController.perform(selector, with: NSArray(array: detents.map { $0.getDetent(viewController) }))
            
            if let lastDetentIndex = lastDetentIndex {
                setDetentIndex(on: presentationController, index: lastDetentIndex)
            }

            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 5,
                initialSpringVelocity: 1,
                options: .allowUserInteraction,
                animations: {
                    presentationController.presentedViewController.view.layoutIfNeeded()
                    presentationController.presentedViewController.view.layoutSuperviewsIfNeeded()
                }, completion: nil
            )
        }

        var rawValue: String {
            switch self {
            case .large:
                return "large"
            case .medium:
                return "medium"
            case .custom:
                return "custom"
            }
        }

        func getDetent(_ presentedViewController: UIViewController) -> NSObject {
            let key = [
                "_", "U", "I", "S", "h", "e", "e", "t", "D", "e", "t", "e", "n", "t",
            ]

            let DetentsClass = NSClassFromString(key.joined()) as! NSObject.Type

            switch self {
            case .large, .medium:
                return DetentsClass.value(forKey: "_\(rawValue)Detent") as! NSObject
            case let .custom(containerViewBlock):
                typealias ContainerViewBlockMethod = @convention(c) (
                    NSObject.Type,
                    Selector,
                    @escaping (_ containerView: UIView) -> Double
                ) -> NSObject
                let customKey = [
                    "_detent",
                    "WithContainerViewBlock",
                    ":",
                ]
                let selector = NSSelectorFromString(customKey.joined())
                let method = DetentsClass.method(for: selector)
                let castedMethod = unsafeBitCast(method, to: ContainerViewBlockMethod.self)

                return castedMethod(DetentsClass, selector) { view in
                    Double(containerViewBlock(presentedViewController, view))
                }
            }
        }
    }

    public static func detented(_ detents: Detent..., modally: Bool = true) -> PresentationStyle {
        PresentationStyle(name: "detented") { viewController, from, options in
            if #available(iOS 13, *) {
                if modally {
                    let vc = viewController.embededInNavigationController(options)

                    let delegate = DetentedTransitioningDelegate(
                        detents: detents,
                        wantsGrabber: options.contains(.wantsGrabber),
                        viewController: viewController
                    )
                    vc.transitioningDelegate = delegate
                    vc.modalPresentationStyle = .custom

                    return from.modallyPresentQueued(vc, options: options) {
                        modalPresentationDismissalSetup(for: vc, options: options)
                    }
                } else {
                    let bag = DisposeBag()

                    if let navigationController = from.navigationController, let presentationController = navigationController.presentationController {
                        from.lastDetentIndex = getDetentIndex(on: presentationController)

                        Self.Detent.set(
                            detents,
                            on: presentationController,
                            viewController: viewController
                        )
                        setGrabber(on: presentationController, to: options.contains(.wantsGrabber))

                        bag += navigationController.willPopViewControllerSignal.wait(
                            until: navigationController.interactivePopGestureRecognizer?.map { $0 == .possible || $0 == .ended } ?? ReadSignal(true)
                        ).debug()
                            .filter(predicate: { $0 == viewController })
                            .onValue { _ in
                                guard let previousViewController = navigationController.viewControllers.last else {
                                    return
                                }

                                func handleDismiss() {
                                    navigationController.view.backgroundColor = previousViewController.view.backgroundColor
                                    Self.Detent.set(
                                        previousViewController.appliedDetents,
                                        on: presentationController,
                                        viewController: previousViewController,
                                        lastDetentIndex: previousViewController.lastDetentIndex
                                    )
                                }

                                if navigationController.interactivePopGestureRecognizer?.state == .ended, !(navigationController.transitionCoordinator?.isCancelled ?? false) {
                                    handleDismiss()
                                } else if navigationController.interactivePopGestureRecognizer?.state == .possible {
                                    handleDismiss()
                                }
                            }
                    }

                    let defaultPresentation = PresentationStyle.default.present(viewController, from: from, options: options)

                    return (defaultPresentation.result, {
                        bag.dispose()
                        return defaultPresentation.dismisser()
                    })
                }
            } else {
                if modally {
                    return PresentationStyle.modal.present(viewController, from: from, options: options)
                }

                return PresentationStyle.default.present(viewController, from: from, options: options)
            }
        }
    }
}
